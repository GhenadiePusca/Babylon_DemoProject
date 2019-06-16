//
//  PostListItemTableViewCell.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

final class PostListItemTableViewCell: UITableViewCell {
    static let reuseIdentifier = "\(PostListItemTableViewCell.self)"

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupStyling()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(viewModel: PostListItemViewModel) {
        textLabel?.text = viewModel.postName
    }
    
    private func setupStyling() {
        textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        textLabel?.numberOfLines = 0
        textLabel?.lineBreakMode = .byWordWrapping
        textLabel?.textColor = .gray
    }
}
