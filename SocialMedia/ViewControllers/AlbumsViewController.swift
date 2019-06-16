//
//  AlbumsViewController.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 29/05/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit
import VK_ios_sdk


class AlbumsViewController: UITableViewController {
    
    var model: Model?
    private var networkManager: NetworkController?
    private var userManager: UsersController?
    
    private var activityIndicator = UIActivityIndicatorView(style: .gray)
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    @IBAction func logoutButton(_ sender: Any) {
        logout()
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()
        
        setupActivityIndicator()
        setupRefreshControl()
        setupManagers()
        setAvatar(with: UIImage(named: "avatar_placeholder"))
        
        loadData(completion: {})
        userManager?.loadUserInfo()
    }
    
    
    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender:  Any?) {
        if let controller = (segue.destination as? UINavigationController)?.viewControllers.first as? MyInfoViewController {
            guard let model = model else { return }
            controller.user = model.user
        } else if let controller = (segue.destination as? ImagesViewController) {
            guard
                let selectedCellIndexRow = tableView.indexPathForSelectedRow?.row,
                let model = model
                else { return }
            controller.album = model.albums[selectedCellIndexRow]
            controller.token = model.token
        }
    }
    
    
    override func shouldPerformSegue(withIdentifier identifier: String?, sender: Any?) -> Bool {
        guard
            let selectedCellIndexRow = tableView.indexPathForSelectedRow?.row,
            let model = model,
            let identifier = identifier
            else { return true }
        
        if identifier == "toPhotos" {
            if model.albums[selectedCellIndexRow].countOfImage == 0 {
                return false
            }
        }
        
        return true
    }
    
    
    @objc func ShowUserInfo() {
        performSegue(withIdentifier: "userInfoSegue", sender: self)
    }
    
}



// MARK: - UI activities and other...

private extension AlbumsViewController {
    
    func setupManagers() {
        networkManager = NetworkController()
        networkManager?.delegate = self
        networkManager?.alertDelegate = self
        
        userManager = UsersController()
        userManager?.avatarDelegate = self
        userManager?.alertDelegate = self
        userManager?.model = model
    }
    
    
    func setupActivityIndicator() {
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
    }
    
    
    func logout() {
        VKSdk.forceLogout()
        guard let model = model else { return }
        model.token = nil
        
        navigationController?.popViewController(animated: true)
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

extension AlbumsViewController: NetworkDelegate {
    
    func loadData(completion: @escaping () -> Void) {
        guard
            let model = model,
            let token = model.token
            else { self.stopRefreshingUI(); return }
        
        let albumsRequest = Request(.albums, params: ["need_system=1&need_covers=1"], token: token)
        networkManager?.downloadData(for: albumsRequest) { [weak self] (albums) in
            guard
                let self = self,
                let albums = albums as? [AlbumVK]
                else { return }
            
            self.model?.albums = albums
            
            DispatchQueue.main.async {
                self.stopRefreshingUI()
                self.tableView.reloadData()
            }
            completion()
        }
    }
    
    
    func parseData(_ data: Data) -> Any {
        var albums: AlbumsVK?
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        
        do {
            albums = try decoder.decode(AlbumsVK.self, from: data)
        } catch {
            print("Error while parsing JSON within 'parsingJSON': " + error.localizedDescription)
            didReceive(error: error)
        }
        
        print("Data was updated")
        
        guard let unwrappedAlbums = albums else { return [] }
        return unwrappedAlbums.albums
    }
    
}



// MARK: - AvatarDelegate

extension AlbumsViewController: AvatarDelegate {
    
    func setAvatar(with image: UIImage?) {
        guard
            let image = image,
            let navigationController = self.navigationController
            else { return }
        
        let barHeight = navigationController.navigationBar.bounds.height - 15
        
        let button = UIButton()
        button.setBackgroundImage(image, for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: barHeight, height: barHeight)
        button.layer.cornerRadius = barHeight / 2
        button.layer.masksToBounds = true
        
        button.addTarget(self, action: #selector(ShowUserInfo), for: .touchUpInside)
        
        let barView = UIView(frame: CGRect(x: 0, y: 0, width: barHeight, height: barHeight))
        barView.addSubview(button)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: barView)
    }
    
}



// MARK: - AlertDelegate

extension AlbumsViewController: AlertDelegate {
    
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

extension AlbumsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.model?.albums.count ?? 0
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AlbumCell", for: indexPath) as? AlbumCell
        
        let albumForCell = self.model?.albums[indexPath.row]
        guard let unwrappedAlbumForCell = albumForCell else { return UITableViewCell() }
        
        cell?.setupCell(album: unwrappedAlbumForCell)
        guard let unwrappedCell = cell else { return UITableViewCell() }
        
        return unwrappedCell
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

