//
//  NewNetworkController.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 03/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit
import VK_ios_sdk


protocol NetworkDelegate: class {
    func loadData(completion: @escaping () -> Void)
    func parseData(_ data: Data) -> Any
}



class NetworkController {
    
    weak var delegate: NetworkDelegate?
    weak var alertDelegate: AlertDelegate?
    
    
    func downloadData(for request: Request, completionHandler: @escaping (Any) -> ()) {
        guard let url = request.absolutURL else { return }
        var parsedData: Any?
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            guard let error = error else {
                print("Data was loaded")
                
                parsedData = self.delegate?.parseData(data!)
                
                guard let parsedData = parsedData else { return }
                completionHandler(parsedData)
                return
            }
            
            print("Error within 'loadData': " + error.localizedDescription)
            self.alertDelegate?.didReceive(error: error)
        }
        
        task.resume()
    }
    
    
    class func downloadImage(from url: URL?, completionHandler: @escaping (UIImage?) -> ()) {
        guard let url = url else { return }
        
        DispatchQueue.global(qos: .background).async {
            guard
                let imageData = try? Data(contentsOf: url),
                let image = UIImage(data: imageData)
                else {
                    completionHandler(nil)
                    return
            }
            completionHandler(image)
        }
    }

}
