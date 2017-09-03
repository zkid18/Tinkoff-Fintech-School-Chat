//
//  PresentPhotoFromInternetViewController.swift
//  Tinkoff Chat
//
//  Created by Даниил on 11.05.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

protocol IPresentaionPhotoFormInternetDelegate {
    func setNewImage(imageToShow: UIImage)
}

class PresentPhotoFromInternetViewController: UIViewController {

    @IBOutlet weak var phpotCollectionView: UICollectionView!
    
    let photoModel = PhotoModel(photoService: PhotoService())
    var dataSource = [PhotoApiModel]()
    let bounds = UIScreen.main.bounds
    
    var iamgeToSend: UIImage?
    
    var delegate: IPresentaionPhotoFormInternetDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        phpotCollectionView.allowsMultipleSelection = false
        
        photoModel.fetchPhotos(completionHandler: { [unowned self] _ in
            self.dataSource = self.photoModel.photosToShow
            
            DispatchQueue.main.async {
                self.phpotCollectionView.reloadData()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendPhotoToPreviousController(_ sender: Any) {
        
        delegate?.setNewImage(imageToShow: iamgeToSend!)
        
        _ = self.navigationController?.popViewController(animated: true)
        
        // If you are presenting this controller then you need to dismiss
        self.dismiss(animated: true)
        
    }
    
}

extension PresentPhotoFromInternetViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "sampleCell", for: indexPath) as! photoCollectionViewCell
        let photos = dataSource[indexPath.row]
        let photosUrl = URL(string: photos.url)
        
        let backgroundQueue = DispatchQueue(label: "backgroundQueue", qos: .background, attributes: .concurrent, autoreleaseFrequency: .inherit, target: nil)
        //cell.photoImageView.image = UIImage(named: "samplePhoto")
        
        backgroundQueue.async {
            if let imageData = try? Data(contentsOf: photosUrl!) {
                DispatchQueue.main.async {
                    cell.photoImageView.image = UIImage(data: imageData)
                }
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! photoCollectionViewCell
        
        print("Cell is selected")
        iamgeToSend = cell.photoImageView.image
        cell.selectedView.backgroundColor = UIColor.green
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        let cell = collectionView.cellForItem(at: indexPath) as! photoCollectionViewCell
        
        print("Cell is selected")
        cell.selectedView.backgroundColor = UIColor.clear
    }
}



extension PresentPhotoFromInternetViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: bounds.width/3.5, height: bounds.width/3.5)
    }
}
