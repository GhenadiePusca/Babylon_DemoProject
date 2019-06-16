//
//  UIViewController+Loading.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

fileprivate let overlayViewTag = 999
fileprivate let activityIndicatorTag = 1000

extension UIViewController {
    public func setActivityIndicator() -> Void {
        guard !isDisplayingActivityIndicatorOverlay() else { return }
        guard let parentViewForOverlay = navigationController?.view ?? view else { return }
        
        let overlay = UIView()
        overlay.translatesAutoresizingMaskIntoConstraints = false
        overlay.backgroundColor = UIColor.black
        overlay.alpha = 0.5
        overlay.tag = overlayViewTag
        
        let activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.tag = activityIndicatorTag
        
        overlay.addSubview(activityIndicator)
        parentViewForOverlay.addSubview(overlay)
        
        overlay.heightAnchor.constraint(equalTo: parentViewForOverlay.heightAnchor).isActive = true
        overlay.widthAnchor.constraint(equalTo: parentViewForOverlay.widthAnchor).isActive = true
        
        activityIndicator.centerXAnchor.constraint(equalTo: overlay.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: overlay.centerYAnchor).isActive = true
        
        
        activityIndicator.startAnimating()
    }
    
    public func removeActivityIndicator() -> Void {
        let activityIndicator = getActivityIndicator()
        
        if let overlayView = getOverlayView() {
            UIView.animate(withDuration: 0.3, animations: {
                overlayView.alpha = 0.0
                activityIndicator?.stopAnimating()
            }) { (finished) in
                activityIndicator?.removeFromSuperview()
                overlayView.removeFromSuperview()
            }
        }
    }
    
    private func isDisplayingActivityIndicatorOverlay() -> Bool {
        if let _ = getActivityIndicator(), let _ = getOverlayView() {
            return true
        }
        return false
    }
    
    private func getActivityIndicator() -> UIActivityIndicatorView? {
        return (navigationController?.view.viewWithTag(activityIndicatorTag) ?? view.viewWithTag(activityIndicatorTag)) as? UIActivityIndicatorView
    }
    
    private func getOverlayView() -> UIView? {
        return navigationController?.view.viewWithTag(overlayViewTag) ?? view.viewWithTag(overlayViewTag)
    }
}

