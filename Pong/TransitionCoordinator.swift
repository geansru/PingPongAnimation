import Foundation
import UIKit

final class TransitionCoordinator: NSObject, UINavigationControllerDelegate {

  func navigationController(_ navigationController: UINavigationController,
    animationControllerFor operation: UINavigationControllerOperation,
    from fromVC: UIViewController,
    to toVC: UIViewController)
  -> UIViewControllerAnimatedTransitioning? {
    
    return CircularTransition()
  }
}
