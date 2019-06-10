//
//  ImageViewController.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 09/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit
import VK_ios_sdk


class ImageViewController: UIViewController {
    
    var image: ImageVK?
    var navigationBarColor: UIColor?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var photo: UIImageView!
    
    @IBAction func actionButton(_ sender: Any) {
        guard let imageToSend = image?.imageLarge else { return }
        let activityVC = UIActivityViewController(activityItems: [imageToSend], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true, completion: nil)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { return .slide }
    override var prefersStatusBarHidden: Bool { return navigationController?.isNavigationBarHidden == true }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupScrollView()
        setupActivityIndicator()
        loadPhoto()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        navigationController?.navigationBar.barTintColor = .black
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        navigationController?.hidesBarsOnTap = false
        navigationController?.navigationBar.barTintColor = navigationBarColor
    }

}



private extension ImageViewController {
    
    func loadPhoto() {
        guard
            let image = image,
            let url = image.imageLargeURL
            else { return }
        
        NetworkController.downloadImage(from: url) { [weak self] image in
            guard
                let self = self,
                let image = image
                else { return }
            
            self.image?.imageLarge = image
            
            DispatchQueue.main.async {
                self.photo.image = image
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    
    func setupScrollView() {
        scrollView.frame = view.frame
        scrollView.minimumZoomScale = 1
        scrollView.maximumZoomScale = 3
        scrollView.bounces = true
        scrollView.delegate = self
    }
    
    
    func setupNavigationBar() {
        navigationController?.hidesBarsOnTap = true
        navigationBarColor = navigationController?.navigationBar.barTintColor
        navigationController?.navigationBar.barTintColor = .black
    }
    
}



extension ImageViewController: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return photo
    }
    
}
