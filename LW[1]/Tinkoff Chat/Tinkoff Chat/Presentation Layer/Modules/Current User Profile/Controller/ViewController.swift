//
//  ViewController.swift
//  Tinkoff Chat
//
//  Created by Даниил on 03.03.17.
//  Copyright © 2017 Даниил. All rights reserved.
//

import UIKit

class ViewController: BaseAnimationViewController {

    let currentAppUser = AppUser1()
    var appUser: AppUser?
    var userProfileStorage = UserProfileStorageService()
    
    enum SavingInstance {
        case GCD
        case Operation
        case CoreData
    }
    
    enum RetrieveMethod {
        case File
        case CoreData
    }
    
    //MARK: - IBOutlet
    
    @IBOutlet weak var textViewCloseButton: UIBarButtonItem!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var userTextField: UITextField!
    @IBOutlet weak var editPhotoView: UIView!
    @IBOutlet weak var userTextView: UITextView!
    @IBOutlet weak var buttonColorLabel: UILabel!
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var GCDButton: UIButton!
    @IBOutlet weak var OperationButton: UIButton!
    @IBOutlet weak var CoreDataButton: UIButton!
    
    
    let GCDManager = GCDDataManager()
    let operationManager = OperationDataManager()
    
    var defaultRetrieveMethod = RetrieveMethod.CoreData
    
    //MARK: - IBAction
    
    @IBAction func editPhotoButton(_ sender: Any) {
        showAlert()
    }
    
    @IBAction func changeLabelColor(_ sender: UIButton) {
        let button: UIButton = sender
        enableButtons()
        buttonColorLabel.textColor = button.backgroundColor
    }
    
    @IBAction func hideKeyboard(_ sender: Any) {
        userTextView.resignFirstResponder()
    }
    
    
    @IBAction func GCDAction(_ sender: Any) {
        saveViaGCD()
    }
    
    @IBAction func CollectionAction(_ sender: Any) {
        saveViaOperation()
    }

    
    @IBAction func CoreDataAction(_ sender: Any) {
         saveToCoreData()
    }
    
//MARK: viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textViewCloseButton.isEnabled = false
        activityIndicator.isHidden = true
        disableButtons()
        
        retrieveData(type: defaultRetrieveMethod)
    }
      
    func disableButtons() {
        GCDButton.isEnabled = false
        OperationButton.isEnabled = false
        CoreDataButton.isEnabled = false
    }
    
    
    func enableButtons() {
        
        if defaultRetrieveMethod == RetrieveMethod.File {
            GCDButton.isEnabled = true
            OperationButton.isEnabled = true
        } else {
            CoreDataButton.isEnabled = true
        }
    }
    

    
    func showSuccessAlert() {
        let alertController = UIAlertController(title: "Данные сохранены", message: nil, preferredStyle: .alert)
        let okButoon = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(okButoon)
        self.present(alertController, animated: true)
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    
    
    func showUnsuccessAlert(type: SavingInstance) {
        let alertController = UIAlertController(title: "Ошибка", message: "Не удалось сохранить данные", preferredStyle: .alert)
        let okButoon = UIAlertAction(title: "OK", style: .default)
        
        let repeatButton = UIAlertAction(title: "Повторить", style: .default) { [unowned self] action in
            if type == .GCD {
                self.saveViaGCD()
            }
            if type == .Operation {
                self.saveViaOperation()
            }
            if type == .CoreData {
                self.saveToCoreData()
            }
        }
        alertController.addAction(okButoon)
        alertController.addAction(repeatButton)
        self.present(alertController, animated: true)
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
    
    func retrieveData(type: RetrieveMethod) {
        
        if type == .File {
            let currentUser = AppUser1()
            currentUser.getFromFile { [unowned self] (userName, userDescription, imageData, colorData) in
                self.userTextField.text = userName
                self.userTextView.text = userDescription
                self.buttonColorLabel.textColor =  NSKeyedUnarchiver.unarchiveObject(with: colorData) as? UIColor
                self.profileImage.image = UIImage(data: imageData)
            }
        }
        
        if type == .CoreData {
            userProfileStorage.getUserProfileViaCoreData {[unowned self] (userName, userDescription, imageData) in
                self.userTextField.text = userName
                self.userTextView.text = userDescription
                
                if let data = imageData {
                    self.profileImage.image = UIImage(data: data as Data)
                }
            }
        }
    }
}

//MARK: -UITextFieldDelegate
extension ViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        enableButtons()
    }
}

extension ViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        textViewCloseButton.isEnabled = true
        enableButtons()
    }
}

//MARK: -UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate  {
    
    func showAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let changePhotoAction = UIAlertAction(title: "Выбрать из галереи", style: .default, handler: { [unowned self] action in self.showGalery() })
        let makePhotoAction = UIAlertAction(title: "Сделать фото с камеры", style: .default, handler: { [unowned self] action in self.showCamera()})
        let downloadPhotoFromInternetAction = UIAlertAction(title: "Загрузить фото с интернета", style: .default, handler: { [unowned self] action in self.downloadPhoto()})
        let cancel = UIAlertAction(title: "Выход", style: .cancel)
        alertController.addAction(changePhotoAction)
        alertController.addAction(makePhotoAction)
        alertController.addAction(downloadPhotoFromInternetAction)
        alertController.addAction(cancel)
        self.present(alertController, animated: true)
    }
    
    func showCamera() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func showGalery() {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            imagePicker.allowsEditing = false
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func downloadPhoto() {
        
        self.performSegue(withIdentifier: "showPhotoFromInternet", sender: nil)
        
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else { return }
            profileImage.image = pickedImage
            enableButtons()
            dismiss(animated: true, completion: nil)
    }
}

extension ViewController: IPresentaionPhotoFormInternetDelegate {
    
    func setNewImage(imageToShow: UIImage) {
        profileImage.image = imageToShow
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PresentPhotoFromInternetViewController {
            destination.delegate = self
        }
    }
    
}

// MARK: Saving logic
extension ViewController {
    
    func saveViaOperation() {
        
        launchActivityIndicator()
        
        let currentUser = AppUser1(name: userTextField.text!, description: userTextView.text, color: buttonColorLabel.textColor, image: profileImage.image!)
        
        currentUser.saveUserViaOperation(completed: { [unowned self] _ in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.showSuccessAlert()
            }
            self.disableButtons()
            
        }) { [unowned self] _ in
            self.showUnsuccessAlert(type: .Operation)
            print("Operation: erorr")
        }
        
        enableButtons()
    }
    
    func saveViaGCD(){
        
        launchActivityIndicator()
        
        let currentUser = AppUser1(name: userTextField.text!, description: userTextView.text, color: buttonColorLabel.textColor, image: profileImage.image!)
        
        currentUser.saveUserViaGCD(completed: { [unowned self] _ in
            print("Button tapped")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.showSuccessAlert()
            }
            self.disableButtons()
        }) { [unowned self] _ in
            self.showUnsuccessAlert(type: .GCD)
        }
        
        enableButtons()
    }
    
    private func launchActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        print("GCD")
    }
    
    func saveToCoreData() {
        
        launchActivityIndicator()
        
        userProfileStorage.saveUserProfileViaCoreData(text: userTextField.text!, description: userTextView.text, image: profileImage.image!, completionHandler: { [unowned self] _ in
            print("Button tapped")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.showSuccessAlert()
            }
            self.disableButtons()
            }, failure: { [unowned self] _ in
               self.showUnsuccessAlert(type: .CoreData)
        })
        enableButtons()
    }
}

