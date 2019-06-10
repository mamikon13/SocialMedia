//
//  PhotosViewController.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 02/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit
import VK_ios_sdk


class ImagesViewController: UITableViewController {
    
    var album: AlbumVK?
    var token: VKAccessToken?
    private var networkManager: NetworkController?
    
    private var activityIndicator = UIActivityIndicatorView(style: .gray)
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        
        setupActivityIndicator()
        setupRefreshControl()
        setupManagers()
        
        loadData(completion: {})
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender:  Any?) {
        guard
            let selectedCellIndexRow = tableView.indexPathForSelectedRow?.row,
            let vc = (segue.destination as? ImageViewController)
            else { return }
        
        vc.image = album?.images[selectedCellIndexRow]
    }
    
}



// MARK: - UI activities and other...

private extension ImagesViewController {
    
    func setupManagers() {
        networkManager = NetworkController()
        networkManager?.delegate = self
        networkManager?.alertDelegate = self
    }
    
    
    func setURLs(for images: [ImageVK]?) -> [ImageVK] {
        guard let images = images else { return [] }
        var fillImages: [ImageVK] = []
        
        for var image in images {
            let sizes = image.imageSizes
            for size in sizes {
                if size.type == "m" {
                    image.imageSmallURL = size.url
                }
                
                if size.type == "r" {
                    image.imageLargeURL = size.url
                } else if size.type == "w" {
                    image.imageLargeURL = size.url
                } else if size.type == "z" {
                    image.imageLargeURL = size.url
                }
            }
            fillImages.append(image)
        }
        return fillImages
    }
    
    
    func sortImagesByDate() {
        guard let album = album else { return }
        
        let sortedImages = album.images.sorted {
            $0.loadDate > $1.loadDate   // firstly newest images
        }
        
        self.album?.images = sortedImages
    }
    
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    
    func setupRefreshControl() {
        refreshControl = UIRefreshControl()
        
        refreshControl?.addTarget(self,
                                  action: #selector(handleRefresh),
                                  for: .valueChanged)
        refreshControl?.tintColor = UIColor.black
        
        guard let unwrappedRefreshControl = refreshControl else { return }
        view.addSubview(unwrappedRefreshControl)
    }
    
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        loadData(completion: {})
    }
    
    
    func stopRefreshingUI() {
        refreshControl?.endRefreshing()
        activityIndicator.stopAnimating()
    }
    
}



// MARK: - NetworkDelegate

extension ImagesViewController: NetworkDelegate {
    
    func loadData(completion: @escaping () -> Void) {
        guard
            let album = album,
            let token = token
            else { self.stopRefreshingUI(); return }
        
        let imagesRequest = Request(.photos, params: ["album_id=\(album.id)&extended=1"], token: token)
        networkManager?.downloadData(for: imagesRequest) { [weak self] (imagesInAlbum) in
            guard
                let self = self,
                let imagesInAlbum = imagesInAlbum as? [ImageVK]
                else { return }
            
            self.album?.images = self.setURLs(for: imagesInAlbum)
            self.sortImagesByDate()
            
            DispatchQueue.main.async {
                self.stopRefreshingUI()
                self.tableView.reloadData()
            }
        }
        completion()
    }
    
    
    func parseData(_ data: Data) -> Any {
        var images: ImagesVK?
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        do {
            images = try decoder.decode(ImagesVK.self, from: data)
        } catch {
            print("Error while parsing JSON within 'parsingJSON': " + error.localizedDescription)
            didReceive(error: error)
        }
        
        print("Data was updated")
        
        guard let unwrappedImages = images else { return [] }
        return unwrappedImages.images
    }
    
}



// MARK: - AlertDelegate

extension ImagesViewController: AlertDelegate {
    
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
            self.present(errorAlert, animated: true, completion: { self.stopRefreshingUI() })
        }
    }
    
}



// MARK: - Table view data source

extension ImagesViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.album?.images.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as? ImageCell
        
        let imageForCell = self.album?.images[indexPath.row]
        guard let unwrappedImageForCell = imageForCell else { return UITableViewCell() }
        
        cell?.initCell(image: unwrappedImageForCell)
        guard let unwrappedCell = cell else { return UITableViewCell() }
        
        return unwrappedCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}
