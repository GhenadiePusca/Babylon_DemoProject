//
//  ErrorStateView.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit

final class ErrorStateView: UIView {
    
    // MARK: - Action handler
    
    var onActionTriggered: () -> () = { }
    
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
        let button = makeButton()
        let messageLabel = makeMessageLabel()
        
        addSubview(button)
        addSubview(messageLabel)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.7),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -16)
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
        button.addTarget(self, action: #selector(actionTriggered), for: .touchUpInside)
        button.layer.cornerRadius = 5
        
        return button
    }
    
    // MARK: - Action
    @objc private func actionTriggered() {
        onActionTriggered()
    }
}

