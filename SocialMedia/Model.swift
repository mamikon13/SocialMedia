//
//  Model.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 28/05/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit
import VK_ios_sdk


class Model: NSObject {
    
    var albums: [AlbumVK] = []
    var user: UserVK?
    
    private let appId = "7000529"
    var sdkInstance: VKSdk?
    let scopes = [VK_PER_AUDIO, VK_PER_PHOTOS]
    var token: VKAccessToken?
    
    let logoutURL = "http://api.vk.com/oauth/logout"
    
    
    override init() {
        super.init()
        
        sdkInstance = VKSdk.initialize(withAppId: appId)
        token = VKSdk.accessToken()
        
        checkSessionAndAuthorize()
    }
    
    
    private func checkSessionAndAuthorize() {
        VKSdk.wakeUpSession(self.scopes) { state, error in
            if state == VKAuthorizationState.authorized {
                print("VKAuthorizationState = Authorized")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
}
