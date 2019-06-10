//
//  UserInfoViewController.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 07/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit


class MyInfoViewController: UIViewController {
    
    var user: UserVK?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var userIdLabel: UILabel!
    
    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
    override func viewDidLoad() {
        setUserInfo()
    }
    
}



private extension MyInfoViewController {
    
    func setUserInfo() {
        guard let user = user else { return }
        userNameLabel.text = "\(user.firstName) \(user.lastName)"
        userIdLabel.text = "id: " + String(user.id)
        
        DispatchQueue.main.async {
            self.setAvatar(with: user.avatarLarge)
        }
    }
    
    
    func setAvatar(with image: UIImage?) {
        guard
            let image = image,
            let avatar = avatarImage
            else { return }
        
        avatar.image = image
        avatar.layer.cornerRadius = avatar.frame.width / 2
    }
    
}
