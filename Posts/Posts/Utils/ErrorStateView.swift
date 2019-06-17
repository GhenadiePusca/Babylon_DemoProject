//
//  ErrorStateView.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit
import RxCocoa

final class ErrorStateView: UIView {
    
    // MARK: - Action handler
    
    lazy var reloadButton: UIButton = makeButton()
    
    // MARK: - Initialisation
    init() {
        super.init(frame: .zero)
        setupLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    private func setupLayout() {
        let messageLabel = makeMessageLabel()
        
        addSubview(reloadButton)
        addSubview(messageLabel)
        
        reloadButton.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            reloadButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            reloadButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            reloadButton.heightAnchor.constraint(equalToConstant: 50),
            reloadButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: reloadButton.topAnchor, constant: -16)
            ])
    }
    
    // MARK: - Components factory
    
    private func makeMessageLabel() -> UILabel {
        let messageLabel = UILabel()
        messageLabel.text = "Failed to load posts"
        messageLabel.textAlignment = .center
        messageLabel.textColor = .lightGray
        
        return messageLabel
    }
    
    private func makeButton() -> UIButton {
        let button = UIButton()
        button.setTitle("Try again", for: .normal)
        button.backgroundColor = .purple
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        
        return button
    }
}

