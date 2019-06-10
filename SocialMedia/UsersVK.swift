//
//  UserVK.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 02/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit


struct UsersVK {
    let users: [UserVK]
}


extension UsersVK: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case response = "response"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.users = try container.decode([UserVK].self, forKey: .response)
    }
    
}



struct UserVK {
    let id: Int
    let firstName: String
    let lastName: String
    let avatarURL_50px: URL?
    let avatarURL_200px: URL?
    
    var avatarSmall: UIImage?
    var avatarLarge: UIImage?
}


extension UserVK: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case firstName = "first_name"
        case lastName = "last_name"
        case avatarURL_50px = "photo_50"
        case avatarURL_200px = "photo_200"
    }
}
