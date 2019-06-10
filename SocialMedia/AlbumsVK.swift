//
//  AlbumsVK.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 03/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit


struct AlbumsVK {
    let albums: [AlbumVK]
}


extension AlbumsVK: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case response = "response"
        
        enum ItemsCodingKeys: String, CodingKey {
            case items = "items"
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let itemsContainer = try container.nestedContainer(keyedBy: CodingKeys.ItemsCodingKeys.self, forKey: .response)
        
        self.albums = try itemsContainer.decode([AlbumVK].self, forKey: .items)
    }
    
}



struct AlbumVK {
    let id: Int
    let title: String
    let description: String?
    let createDate: Date?
    let countOfImage: Int
    let coverURL: URL?
    
    var cover: UIImage?
    var images: [ImageVK] = []
}


extension AlbumVK: Decodable {
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case title = "title"
        case description = "description"
        case createDate = "created"
        case countOfImage = "size"
        case coverURL = "thumb_src"
    }
}
