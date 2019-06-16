//
//  PostsListViewModel.swift
//  Posts
//
//  Created by Pusca Ghenadie on 16/06/2019.
//  Copyright © 2019 Pusca Ghenadie. All rights reserved.
//

import RxSwift
import RxCocoa

public final class PostsListViewModel {
    public let postsModels: Driver<[PostListItemViewModel]>
    public let isLoading: Driver<Bool>
    public let loadingFailed: Driver<Bool>
    
    private let models = BehaviorRelay<[PostListItemViewModel]>(value: [])
    private let loading = BehaviorRelay<Bool>(value: false)
    private let loadingFail = BehaviorRelay<Bool>(value: false)
    private let disposeBag = DisposeBag()
    
    public init(dataLoader: Observable<Loadable<[PostListItemModel]>>) {
        postsModels = models.asDriver()
        isLoading = loading.asDriver()
        loadingFailed = loadingFail.asDriver()
        
        bindToDataLoader(loader: dataLoader)
    }
    
    private func bindToDataLoader(loader: Observable<Loadable<[PostListItemModel]>>) {
        loader.subscribe(onNext: handleState).disposed(by: disposeBag)
    }
    
    private func handleState(_ state: Loadable<[PostListItemModel]>) {
        switch state {
        case .loading:
            loading.accept(true)
            loadingFail.accept(false)
            handleData(data: [])
        case .failed:
            loading.accept(false)
            loadingFail.accept(true)
            handleData(data: [])
        case .loaded(let items):
            loading.accept(false)
            loadingFail.accept(false)
            handleData(data: items)
        default:
            loading.accept(false)
            loadingFail.accept(false)
            handleData(data: [])
        }
    }
    
    private func handleData(data: [PostListItemModel]) {
        models.accept(data.map { PostListItemViewModel(model: $0) })
    }
}
