//
//  PostDetailView.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import UIKit
import RxSwift

final class PostDetailView: UIView {
    struct Constants {
        static let titleFontSize: CGFloat = 22
        static let bodyFontSize: CGFloat = 18
        static let infoFontSize: CGFloat = 14
        static let verticalSpacing: CGFloat = 10
        static let horizontalSpacing: CGFloat = 16
    }

    private let disposeBag = DisposeBag()

    private lazy var titleLabel: UILabel = makeLabel(fontSize: Constants.titleFontSize)
    private lazy var bodyLabel: UILabel = makeLabel(fontSize: Constants.bodyFontSize)
    private lazy var authorNameLabel: UILabel = makeLabel(fontSize: Constants.infoFontSize)
    private lazy var commentsCountLabel: UILabel = makeLabel(fontSize: Constants.infoFontSize)
    private lazy var authorNameLoadingIndicator = UIActivityIndicatorView(style: .gray)
    private lazy var commentsCountLoadingIndicator = UIActivityIndicatorView(style: .gray)

    private let viewModel: PostDetailViewModel
    
    // MARK: - Initialisation

    init(viewModel: PostDetailViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        setupLayout()
        bindToVM()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Bindings

    private func bindToVM() {
        titleLabel.text = viewModel.title
        bodyLabel.text = viewModel.body
        viewModel.authorName.drive(authorNameLabel.rx.text).disposed(by: disposeBag)
        viewModel.authorNameIsLoading.drive(authorNameLoadingIndicator.rx.isAnimating).disposed(by: disposeBag)
        viewModel.authorNameIsLoading.map { !$0 }.drive(authorNameLoadingIndicator.rx.isHidden).disposed(by: disposeBag)
        
        viewModel.numberOfComments.drive(commentsCountLabel.rx.text).disposed(by: disposeBag)
        viewModel.numberOfCommentsIsLoading.drive(commentsCountLoadingIndicator.rx.isAnimating).disposed(by: disposeBag)
        viewModel.numberOfCommentsIsLoading.map { !$0 }.drive(commentsCountLoadingIndicator.rx.isHidden).disposed(by: disposeBag)
    }
    
    // MARK: - Layout

    private func setupLayout() {
        let authorNameContainer = setupAuthorNameContainer()
        let commentsCountContainer = setupCommentsCountContainer()

        let stack = UIStackView(arrangedSubviews: [titleLabel,
                                                   bodyLabel,
                                                   authorNameContainer,
                                                   commentsCountContainer])
        stack.axis = .vertical
        stack.spacing = Constants.verticalSpacing
        stack.alignment = .leading
        stack.distribution = .fill
        
        addSubviewAligned(stack, horizontalSpacing: Constants.horizontalSpacing)
    }
    
    // MARK: - Components Factory

    private func setupInfoContainer(descLabel: UILabel, infoLabel: UILabel, loadingIndicator: UIActivityIndicatorView) -> UIView {
        infoLabel.addSubview(loadingIndicator)
        loadingIndicator.translatesAutoresizingMaskIntoConstraints = false
        loadingIndicator.centerYAnchor.constraint(equalTo: infoLabel.centerYAnchor).isActive = true
        loadingIndicator.leadingAnchor.constraint(equalTo: infoLabel.leadingAnchor).isActive = true

        let container = UIView()
        container.addSubview(descLabel)
        container.addSubview(infoLabel)
        descLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descLabel.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        descLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        descLabel.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        
        infoLabel.centerYAnchor.constraint(equalTo: descLabel.centerYAnchor).isActive = true
        infoLabel.leadingAnchor.constraint(equalTo: descLabel.trailingAnchor, constant: Constants.horizontalSpacing / 2).isActive = true
        infoLabel.trailingAnchor.constraint(lessThanOrEqualTo: container.trailingAnchor, constant: -Constants.horizontalSpacing / 2).isActive = true
        
        return container
    }

    private func setupAuthorNameContainer() -> UIView {
        let authorDescLabel = makeLabel(fontSize: Constants.infoFontSize)
        authorDescLabel.text = "Author: "
        
        return setupInfoContainer(descLabel: authorDescLabel,
                                  infoLabel: authorNameLabel,
                                  loadingIndicator: authorNameLoadingIndicator)
    }
    
    private func setupCommentsCountContainer() -> UIView {
        let commentsCountDescLabel = makeLabel(fontSize: Constants.infoFontSize)
        commentsCountDescLabel.text = "Comments: "
        
        return setupInfoContainer(descLabel: commentsCountDescLabel,
                                  infoLabel: commentsCountLabel,
                                  loadingIndicator: commentsCountLoadingIndicator)

    }
    
    private func makeLabel(fontSize: CGFloat) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: fontSize)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        
        return label
    }
}
