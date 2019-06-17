//
//  UIView+Constraints.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

extension UIView {
    func addSubviewAligned(_ subview: UIView, horizontalSpacing: CGFloat = 0) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
        if #available(iOS 11, *) {
            let guide = safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                subview.leadingAnchor.constraint(equalTo: guide.leadingAnchor, constant: horizontalSpacing),
                subview.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: -horizontalSpacing),
                subview.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                subview.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            
        } else {
            NSLayoutConstraint.activate([
                subview.topAnchor.constraint(equalTo: topAnchor),
                subview.leadingAnchor.constraint(equalTo: leadingAnchor),
                subview.trailingAnchor.constraint(equalTo: trailingAnchor),
                subview.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
        }
    }
}
