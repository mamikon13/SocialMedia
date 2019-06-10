//
//  Image.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 29/05/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit


struct ImageSize {
    let type: String
    let url: URL
}

extension ImageSize: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case type = "type"
        case url = "url"
    }
}



struct ImagesVK {
    let images: [ImageVK]
}


extension ImagesVK: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case response = "response"
        
        enum ItemsCodingKeys: String, CodingKey {
            case items = "items"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let itemsContainer = try container.nestedContainer(keyedBy: CodingKeys.ItemsCodingKeys.self, forKey: .response)
        
        self.images = try itemsContainer.decode([ImageVK].self, forKey: .items)
    }
    
}



struct ImageVK {
    let text: String
    let loadDate: Date
    let ownerId: Int
    let imageSizes: [ImageSize]
    
    let likesCount: Int
    let repostsCount: Int
    let commentsCount: Int
    
    var ownerName: String?
    var imageSmallURL: URL?
    var imageLargeURL: URL?
    var imageSmall: UIImage?
    var imageLarge: UIImage?
}


extension ImageVK: Decodable {

    private enum CodingKeys: String, CodingKey {
        case text = "text"
        case loadDate = "date"
        case ownerID = "owner_id"
        case imageSizes = "sizes"
        
        case likesCount = "likes"
        case repostsCount = "reposts"
        case commentsCount = "comments"

        enum ImageSizesCodingKeys: String, CodingKey {
            case type = "type"
            case imageURL = "url"
        }

        enum CommunityActivityCodingKeys: String, CodingKey {
            case count = "count"
        }
    }

    init(from decoder: Decoder) throws {

        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.text = try container.decode(String.self, forKey: .text)
        self.loadDate = try container.decode(Date.self, forKey: .loadDate)
        self.ownerId = try container.decode(Int.self, forKey: .ownerID)
        self.imageSizes = try container.decode([ImageSize].self, forKey: .imageSizes)


        // Extended info from VK SDK
        var CommunityActivityCodingKeys = try container.nestedContainer(keyedBy: CodingKeys.CommunityActivityCodingKeys.self, forKey: .likesCount)
        self.likesCount = try CommunityActivityCodingKeys.decode(Int.self, forKey: .count)
        
        CommunityActivityCodingKeys = try container.nestedContainer(keyedBy: CodingKeys.CommunityActivityCodingKeys.self, forKey: .repostsCount)
        self.repostsCount = try CommunityActivityCodingKeys.decode(Int.self, forKey: .count)
        
        CommunityActivityCodingKeys = try container.nestedContainer(keyedBy: CodingKeys.CommunityActivityCodingKeys.self, forKey: .commentsCount)
        self.commentsCount = try CommunityActivityCodingKeys.decode(Int.self, forKey: .count)
    }

}
