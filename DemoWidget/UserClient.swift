//
//  UserClient.swift
//  DemoWidget
//
//  Created by victor.cuaca on 03/09/23.
//

import Foundation

struct User: Identifiable {
    let id: Int
    let name: String
    let username: String
}

extension User: Decodable {}

extension Array where Element == User {
    static var templates: [User] {
        [
            User(id: 1, name: "Leanne Graham", username: "Bret"),
            User(id: 2, name: "Ervin Howell", username: "Antonette"),
            User(id: 3, name: "Clementine Bauch", username: "Samantha"),
        ]
    }
}

struct UserClient {
    var getUsers: () async throws -> [User]
}

extension UserClient {
    static var live: UserClient {
        UserClient(
            getUsers: {
                let url = URL(string: "https://jsonplaceholder.typicode.com/users")!
                let (data, _) = try await URLSession.shared.data(from: url)
                let users = try JSONDecoder().decode([User].self, from: data)
                return users
            }
        )
    }
}
