//
//  PostDetailView.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

final class PostDetailView: UIView {
    lazy var titleLabel: UILabel = makeLabel(fontSize: 22)
    lazy var bodyLabel: UILabel = makeLabel(fontSize: 18)
    lazy var authorNameLabel: UILabel = makeLabel(fontSize: 14)
    lazy var commentsCountLabel: UILabel = makeLabel(fontSize: 14)

    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayout() {
        titleLabel.text = "A title"
        bodyLabel.text = "a body"
        authorNameLabel.text = "Author: John"
        commentsCountLabel.text = "Count: 40"

        let stack = UIStackView(arrangedSubviews: [titleLabel,
                                                   bodyLabel,
                                                   authorNameLabel,
                                                   commentsCountLabel])
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        stack.distribution = .fill
        
        addSubviewAligned(stack)
    }
    
    private func makeTitleLabel() -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }
    
    private func makeLabel(fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }
}
