//
//  PostDetailsViewController.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

final class PostDetailsViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Details"
        view.backgroundColor = .white
        
        let detailView = PostDetailView()
        view.addSubview(detailView)
        
        detailView.translatesAutoresizingMaskIntoConstraints = false
        
        if #available(iOS 11, *) {
            let guide = view.safeAreaLayoutGuide
            NSLayoutConstraint.activate([
                detailView.leadingAnchor.constraint(equalTo: guide.leadingAnchor),
                detailView.trailingAnchor.constraint(equalTo: guide.trailingAnchor),
                detailView.topAnchor.constraint(equalToSystemSpacingBelow: guide.topAnchor, multiplier: 1.0),
                ])
        }
    }
}
