//
//  UsersViewController.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 03/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit
import VK_ios_sdk


protocol AvatarDelegate: class {
    func setAvatar(with image: UIImage?)
}

protocol AlertDelegate: class {
    func didReceive(error: Error?)
}



class UsersController {
    
    var model: Model?
    weak var avatarDelegate: AvatarDelegate?
    weak var alertDelegate: AlertDelegate?
    
    
    func parseData(_ data: Data) -> UserVK {
        
        var user = UserVK(id: 0, firstName: "", lastName: "", avatarURL_50px: nil, avatarURL_200px: nil, avatarSmall: nil, avatarLarge: nil)
        var users: UsersVK?
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        do {
            users = try decoder.decode(UsersVK.self, from: data)
        } catch {
            print("Error while parsing JSON within 'parsingJSON': " + error.localizedDescription)
            alertDelegate?.didReceive(error: error)
        }
        
        print("Data was updated")
        
        guard let unwrappedUsers = users else { return user }
        user = unwrappedUsers.users[0]
        
        return user
    }
    
    
    func loadUserInfo() {
        guard let model = model else { return }

        var avatarURL = model.user?.avatarURL_50px
        NetworkController.downloadImage(from: avatarURL) { [weak self] image in
            guard
                let self = self,
                let image = image
                else { return }
            
            self.model?.user?.avatarSmall = image
            
            DispatchQueue.main.async {
                self.avatarDelegate?.setAvatar(with: image)
            }
        }
        
        avatarURL = model.user?.avatarURL_200px
        NetworkController.downloadImage(from: avatarURL) { [weak self] image in
            guard
                let self = self,
                let image = image
                else { return }
            
            self.model?.user?.avatarLarge = image
        }
    }

}



extension UsersController: AlertDelegate {
    
    func didReceive(error: Error?) {
        self.alertDelegate?.didReceive(error: error)
    }

}

