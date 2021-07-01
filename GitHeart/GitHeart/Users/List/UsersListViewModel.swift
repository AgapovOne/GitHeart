//
//  UsersListViewModel.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 26.06.2021.
//

import Foundation

class UsersListViewModel {
    private let api: API
    private let imageProvider: ImageProvider
    private var users: [User] = []
    private var searchText: String = ""
    private var page: Int = 1

    private var isLastPage: Bool = false
    private var searchWorkItem: DispatchWorkItem?

    private(set) var isLoading: Bool = false {
        didSet {
            didChangeLoading?(isLoading)
        }
    }

    var statusText: String? {
        if users.isEmpty {
            return isLoading ? "Loading..." : "Nothing Found"
        }
        return nil
    }

    var didChangeLoading: ((Bool) -> Void)?
    var didUpdateUsersList: (() -> Void)?
    var didFail: ((Error) -> Void)?

    init(api: API, imageProvider: ImageProvider) {
        self.api = api
        self.imageProvider = imageProvider
    }

    func load() {
        guard !isLoading else { return }
        isLoading = true
        api.users(searchTerm: searchText, page: page) { [weak self] result in
            guard let self = self else { return }
            if self.page == 1 {
                self.users = []
            }
            self.isLoading = false
            switch result {
            case let .success(users):
                self.users.append(contentsOf: users)
                self.isLastPage = users.isEmpty
                self.didUpdateUsersList?()
            case let .failure(error):
                self.didFail?(error)
            }
        }
    }

    func loadNextPageIfPossible() {
        guard !isLoading, !isLastPage else { return }
        page += 1
        load()
    }

    func applySearch(text: String) {
        searchText = text
        page = 1
        isLastPage = false

        searchWorkItem?.cancel()
        searchWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            if self.isLoading {
                self.applySearch(text: self.searchText)
            } else {
                self.load()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: searchWorkItem!)
    }

    func numberOfUsers() -> Int {
        return users.count
    }

    func userViewModel(at index: Int) -> UserViewModel {
        let user = self.user(at: index)
        return UserViewModel(login: user.login, avatarUrl: user.avatarUrl, imageProvider: imageProvider)
    }

    func user(at index: Int) -> User {
        return users[index]
    }
}
