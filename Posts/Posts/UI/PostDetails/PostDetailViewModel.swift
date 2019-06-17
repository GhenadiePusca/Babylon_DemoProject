//
//  PostDetailViewModel.swift
//  Posts
//
//  Created by Pusca Ghenadie on 17/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift
import RxCocoa

final class PostDetailViewModel {
    private let diposeBag = DisposeBag()

    var title: String {
        return model.title
    }
    
    var body: String {
        return model.body
    }
    
    let authorName: Driver<String>
    let authorNameIsLoading: Driver<Bool>
    let numberOfComments: Driver<String>
    let numberOfCommentsIsLoading: Driver<Bool>

    private let authorNameBehavior = BehaviorRelay<String>(value: "")
    private let authorNameIsLoadingBehavior = BehaviorRelay<Bool>(value: false)
    private let numberOfCommentsBehavior = BehaviorRelay<String>(value: "--")
    private let numberOfCommentsIsLoadingBehavior = BehaviorRelay<Bool>(value: false)

    private let model: PostDetailsModel

    init(model: PostDetailsModel) {
        self.model = model
        authorName = authorNameBehavior.asDriver()
        authorNameIsLoading = authorNameIsLoadingBehavior.asDriver()
        numberOfComments = numberOfCommentsBehavior.asDriver()
        numberOfCommentsIsLoading = numberOfCommentsIsLoadingBehavior.asDriver()
        
        setupBindings()
    }
    
    private func setupBindings() {
        model.authorName.subscribe(onNext: handlAuthorNameLoading).disposed(by: diposeBag)
        model.numberOfComments.subscribe(onNext: handlCommentsCountLoading).disposed(by: diposeBag)
    }

    private func handlAuthorNameLoading(loadable: Loadable<String>) {
        switch loadable {
        case .pending, .failed:
            authorNameBehavior.accept("Uknown")
            authorNameIsLoadingBehavior.accept(false)
        case .loading:
            authorNameBehavior.accept("")
            authorNameIsLoadingBehavior.accept(true)
        case .loaded(let name):
            authorNameBehavior.accept(name)
            authorNameIsLoadingBehavior.accept(false)
        }
    }
    
    private func handlCommentsCountLoading(loadable: Loadable<Int>) {
        switch loadable {
        case .pending, .failed:
            numberOfCommentsBehavior.accept("--")
            numberOfCommentsIsLoadingBehavior.accept(false)
        case .loading:
            numberOfCommentsBehavior.accept("")
            numberOfCommentsIsLoadingBehavior.accept(true)
        case .loaded(let count):
            numberOfCommentsBehavior.accept(String(count))
            numberOfCommentsIsLoadingBehavior.accept(false)
        }
    }
}
