//
//  CircularTransition.swift
//  Pong
//
//  Created by Dmitriy Roytman on 26.05.2018.
//  Copyright © 2018 Luke Parham. All rights reserved.
//

import UIKit

protocol CircleTransitionable {

  var triggerButton: UIButton { get }
  var contentTextView: UITextView { get }
  var mainView: UIView { get }

}

final class CircularTransition: NSObject, UIViewControllerAnimatedTransitioning {
  
  private weak var context: UIViewControllerContextTransitioning?
  private let duration: TimeInterval = 0.5
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return duration
  }
    
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    guard
      let from      = transitionContext.viewController(forKey: .from) as? CircleTransitionable,
      let to        = transitionContext.viewController(forKey: .to) as? CircleTransitionable,
      let snapshot  = from.mainView.snapshotView(afterScreenUpdates: false)
    else {
        transitionContext.completeTransition(false)
        return
    }
    context = transitionContext
    
    let backgroundView = UIView(frame: to.mainView.frame)
    backgroundView.backgroundColor = from.mainView.backgroundColor
    
    let containerView = transitionContext.containerView
    containerView.addSubview(backgroundView)
    
    containerView.addSubview(snapshot)
    from.mainView.removeFromSuperview()
    
    animateOldTextOffscreen(from: snapshot)
    
    containerView.addSubview(to.mainView)
    animate(to: to.mainView, fromTriggerButton: from.triggerButton)
    animate(toTextView: to.contentTextView, fromTriggerButton: from.triggerButton)
  }
  
  private func animateOldTextOffscreen(from view: UIView) {
    let animations = {
      let oldCenter = view.center
      view.center = CGPoint(x: oldCenter.x - 1300, y: oldCenter.y + 1500)
      
      let scale: CGFloat = 5.0
      view.transform = CGAffineTransform(scaleX: scale, y: scale)
    }
    UIView.animate(withDuration: duration / 2, delay: 0, options: [.curveEaseIn], animations: animations)
  }
  
  private func animate(to view: UIView, fromTriggerButton button: UIButton) {
    let rect = CGRect(origin: button.frame.origin,
                      size: CGSize(width: button.frame.width, height: button.frame.width))
    let circleMaskPathIntial = UIBezierPath(ovalIn: rect)

    let fullHeight = view.bounds.height
    let extremePoint = CGPoint(x: button.center.x,
                               y: button.center.y - fullHeight)
    let radius = sqrt((extremePoint.x * extremePoint.x) + (extremePoint.y * extremePoint.y))

    let finalRect = button.frame.insetBy(dx: -radius, dy: -radius)
    let circleMaskPathFinal = UIBezierPath(ovalIn: finalRect)

    let mask = CAShapeLayer()
    mask.path = circleMaskPathFinal.cgPath
    view.layer.mask = mask

    let maskLayerAnimation = CABasicAnimation(keyPath: "path")
    maskLayerAnimation.fromValue = circleMaskPathIntial.cgPath
    maskLayerAnimation.toValue = circleMaskPathFinal.cgPath
    maskLayerAnimation.duration = 0.15
    maskLayerAnimation.delegate = self

    mask.add(maskLayerAnimation, forKey: "path")
  }

  private func animate(toTextView view: UIView, fromTriggerButton button: UIButton) {
    let originalCenter = view.center
    view.alpha = 0
    view.center = button.center
    let scale: CGFloat = 0.1
    view.transform = CGAffineTransform(scaleX: scale, y: scale)
    
    let animations = {
      view.transform = CGAffineTransform(scaleX: 1, y: 1)
      view.center = originalCenter
      view.alpha = 1
    }
    UIView.animate(withDuration: duration / 2, delay: 0.1, options: [.curveEaseOut], animations: animations)
  }

}

extension CircularTransition: CAAnimationDelegate {
  
  func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
    guard flag else { return }
    context?.completeTransition(true)
  }
}
