//
//  Request.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 01/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit
import VK_ios_sdk


enum MethodName: String {
    case albums = "photos.getAlbums"
    case photos = "photos.get"
    case users = "users.get"
}



struct Request {
    private let startWith = "https://api.vk.com/method/"
    private var method: MethodName
    private var parameters: [String] = []
    private var token: VKAccessToken?
    private var apiVersion: String
    
    var absolutURL: URL?
    
    
    init(_ method: MethodName, params: [String]? = nil, token: VKAccessToken, apiVersion version: String = "5.95") {
        
        self.method = method
        if let params = params {
            self.parameters = params
        }
        self.token = token
        self.apiVersion = version
        
        self.absolutURL = requestURL()
    }
    
    
    private func requestURL() -> URL? {
        guard let token = self.token else { return nil }
        
        var url = ""
        url += self.startWith
        url += self.method.rawValue + "?"
        for parameter in self.parameters {
            url += parameter + "&"
        }
        url += "access_token=" + token.accessToken + "&"
        url += "v=" + self.apiVersion
        
        return URL(string: url)
    }
    
}
