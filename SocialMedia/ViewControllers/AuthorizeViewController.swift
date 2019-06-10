//
//  AuthorizeViewController.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 04/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit
import VK_ios_sdk


class AuthorizeViewController: UIViewController {
    
    var model: Model?
    private var networkManager: NetworkController?
    private var userManager: UsersController?
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }

    @IBOutlet weak var loginButton: UIButton!
    @IBAction func loginButton(_ sender: Any) {
        login()
        
        setupModel()
        loadData() { [weak self] in
            guard let self = self else { return }
            self.performSegue(withIdentifier: "loginSucceed", sender: self)
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLoginButton()
        setupManagers()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        setupModel()
        
        if VKSdk.isLoggedIn() {
            loadData() { [weak self] in
                guard let self = self else { return }
                self.performSegue(withIdentifier: "loginSucceed", sender: self)
            }
        }
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender:  Any?) {
        let vc = (segue.destination as? AlbumsViewController)
        
        guard
            let controller = vc,
            let model = model
            else { return }
        
        controller.model = model
    }
    
}



// MARK: - Setup Model and other...

private extension AuthorizeViewController {
    
    func setupModel() {
        model = Model()
        
        guard
            let model = model,
            let sdkInstance = model.sdkInstance
            else { return }
        
        sdkInstance.register(self)
        sdkInstance.uiDelegate = self
        model.token = VKSdk.accessToken()
    }
    
    
    func setupManagers() {
        networkManager = NetworkController()
        networkManager?.delegate = self
        networkManager?.alertDelegate = self
        
        userManager = UsersController()
        userManager?.alertDelegate = self
    }
    
    
    func login() {
        guard let model = model else { return }
        VKSdk.authorize(model.scopes, with: [.disableSafariController, .unlimitedToken])
    }
    
    
    func setupLoginButton() {
        guard let button = self.loginButton else { return }
        
        let buttonWidth: CGFloat = 120
        let buttonHeight: CGFloat = 40
        let xCoord = self.view.bounds.width / 2 - buttonWidth / 2
        let yCoord = self.view.bounds.height / 2 - buttonHeight / 2
        
        button.frame = CGRect(x: xCoord, y: yCoord, width: buttonWidth, height: buttonHeight)
        button.layer.cornerRadius = buttonHeight / 2
        button.setTitle("Login with VK", for: .normal)
        
        self.view.addSubview(button)
    }
    
}



// MARK: - VK sdk

extension AuthorizeViewController: VKSdkDelegate, VKSdkUIDelegate {
    
    func vkSdkAccessAuthorizationFinished(with result: VKAuthorizationResult!) {
        return
    }
    
    func vkSdkUserAuthorizationFailed() {
        return
    }
    
    func vkSdkShouldPresent(_ controller: UIViewController!) {
        present(controller, animated: true, completion: nil)
        return
    }
    
    func vkSdkNeedCaptchaEnter(_ captchaError: VKError!) {
        return
    }
    
}



// MARK: - NetworkDelegate

extension AuthorizeViewController: NetworkDelegate {
    
    func loadData(completion: @escaping () -> Void) {
        guard
            let model = model,
            let token = model.token
            else { return }
        
        let usersRequest = Request(.users, params: ["fields=photo_50,photo_200"], token: token)
        networkManager?.downloadData(for: usersRequest) { [weak self] (user) in
            guard
                let self = self,
                let user = user as? UserVK
                else { return }
            
            self.model?.user = user
            
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    
    func parseData(_ data: Data) -> Any {
        return userManager?.parseData(data) as Any
    }
    
}



// MARK: - AlertDelegate

extension AuthorizeViewController: AlertDelegate {
    
    func didReceive(error: Error?) {
        guard let unwrappedError = error else { return }
        
        let description = unwrappedError.localizedDescription
        var startIndex = description.debugDescription.firstIndex(of: "\"")
        startIndex = description.debugDescription.index(startIndex!, offsetBy: 1)
        let lastIndex = description.debugDescription.lastIndex(of: "\"")
        
        let errorString = String(description.debugDescription[startIndex!..<lastIndex!])
        
        
        let errorAlert = UIAlertController(title: "Error", message: errorString, preferredStyle: UIAlertController.Style.alert)
        
        let alertAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.cancel, handler: nil)
        errorAlert.addAction(alertAction)
        
        DispatchQueue.main.async {
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
}
