//
//  UsersListProvider.swift
//  GitHeart
//
//  Created by Aleksey Kuznetsov on 03.07.2021.
//

import Foundation

/// A type that provides the list of users.
protocol UsersListProvider {
    /// Requests the list of users by a `page` and applying `searchTerm` if not empty.
    func users(searchTerm: String, page: Int, completion: @escaping ((Result<[User], Error>) -> Void))
}
