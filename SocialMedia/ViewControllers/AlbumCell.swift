//
//  AlbumCell.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 30/05/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit


class AlbumCell: UITableViewCell {
    
    @IBOutlet weak var coverActivityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var cover: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var createDate: UILabel!
    @IBOutlet weak var size: UILabel!
    
    var task: URLSessionTask?
    
    
    func initCell(album: AlbumVK) {
        
        coverActivityIndicator.startAnimating()
        
        title.text = album.title
        createDate.text = String(date: album.createDate)
        size.text = String(album.countOfImage)
        
        task = NetworkController.downloadImage(from: album.coverURL) { [cover, coverActivityIndicator] image in
            DispatchQueue.main.async {
                cover?.image = image
                coverActivityIndicator?.stopAnimating()
            }
        }
    }
    
    
    override func prepareForReuse() {
        cover.image = nil
        task?.cancel()
        super.prepareForReuse()
    }

}
