//
//  BookDetailsViewController.swift
//  SS Book Store
//
//  Created by Soft Space User on 02/07/2021.
//

import UIKit
import AVFoundation

class BookDetailsViewController: UIViewController {

    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainScrollView: UIScrollView!
    @IBOutlet private weak var coverImageView: UIImageView!
    @IBOutlet private weak var imageErrorMsgLabel: UILabel!
    @IBOutlet private weak var nameView: UIView!
    @IBOutlet private weak var authorView: UIView!
    @IBOutlet private weak var descView: UIView!
    @IBOutlet private weak var nameTextField: UITextField!
    @IBOutlet private weak var nameErrorMsgLabel: UILabel!
    @IBOutlet private weak var authorTextField: UITextField!
    @IBOutlet private weak var authorErrorMsgLabel: UILabel!
    @IBOutlet private weak var descTextView: UITextView!
    @IBOutlet private weak var descErrorMsgLabel: UILabel!
    @IBOutlet private weak var editOrSaveButton: UIBarButtonItem!
    
    // MARK: - Variable declaration
    
    internal var bookDetail: BookDetails?
    private var isEditingBook = false
    private var imagePicker: UIImagePickerController!
    private var isCapture: Bool = false
    private var base64ImageString: String = ""
    
    // MARK: - Override func
    
    override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardDisplayNotifications(scrollView: mainScrollView, delegate: self)
        enableHideKeyboardByTappingBackground(cancelsTouchesInView: false)
        setupView()
    }
    
    // MARK: - Private func
    
    private func setupView() {
        if let detail = bookDetail {
            editOrSaveButton.title = "Edit"
            setupViewWithDetail(detail)
        } else {
            isEditingBook = true
            descTextView.textColor = .lightGray
            editOrSaveButton.title = "Done"
            coverImageView.layer.borderWidth = 2
        }
        
        addBorderToView(view: nameView)
        addBorderToView(view: authorView)
        addBorderToView(view: descView)
        
        nameTextField.delegate = self
        authorTextField.delegate = self
        descTextView.delegate = self
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(coverImageViewAction))
        coverImageView.addGestureRecognizer(tapGesture)
        
        coverImageView.layer.cornerRadius = 8
        coverImageView.layer.borderColor = ColorUtil.lightGreen.cgColor
        
        imageErrorMsgLabel.isHidden = true
        nameErrorMsgLabel.isHidden = true
        authorErrorMsgLabel.isHidden = true
        descErrorMsgLabel.isHidden = true
    }
    
    private func addBorderToView(view: UIView) {
        view.layer.cornerRadius = 8
        view.layer.borderWidth = 0.5
        view.layer.borderColor = UIColor.lightGray.cgColor
    }
    
    private func setupViewWithDetail(_ detail: BookDetails) {
        nameTextField.text = detail.bookTitle
        authorTextField.text = detail.authorName
        descTextView.text = detail.description
        coverImageView.image = Util.convertBase64StringToImage(imageBase64String: detail.bookImage)
        base64ImageString = detail.bookImage
        
        setUserInteraction()
        descTextView.textColor = .black
    }
    
    private func updateRightBarButtonText() {
        if isEditingBook {
            editOrSaveButton.title = "Done"
        } else {
            editOrSaveButton.title = "Edit"
        }
    }
    
    private func setUserInteraction() {
        coverImageView.isUserInteractionEnabled = isEditingBook
        nameTextField.isEnabled = isEditingBook
        authorTextField.isEnabled = isEditingBook
        descTextView.isUserInteractionEnabled = isEditingBook
        
        if isEditingBook {
            coverImageView.layer.borderWidth = 2
        } else {
            coverImageView.layer.borderWidth = 0
        }
    }
    
    private func validateTextField() {
        guard !base64ImageString.isEmpty else {
            imageErrorMsgLabel.text = "Book cover is required"
            imageErrorMsgLabel.isHidden = false
            return
        }
        
        guard let title = nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            nameErrorMsgLabel.text = "Book name is required"
            nameErrorMsgLabel.isHidden = false
            return
        }
        
        guard let author = authorTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !author.isEmpty else {
            authorErrorMsgLabel.text = "Author name is required"
            authorErrorMsgLabel.isHidden = false
            return
        }
        
        guard let desc = descTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !desc.isEmpty else {
            descErrorMsgLabel.text = "Book description is required"
            descErrorMsgLabel.isHidden = false
            return
        }
        
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yy"
        
        if var details = bookDetail {
            details.bookTitle = title
            details.authorName = author
            details.description = desc
            details.bookImage = base64ImageString
            details.strDate = formatter.string(from: date)
            
            updateBookDetails(detail: details)
        } else {
            createNewBook(title: title, author: author, desc: desc, image: base64ImageString, date: formatter.string(from: date))
        }
    }
    
    private func updateBookDetails(detail: BookDetails) {
        LoadingScreen.shared.showOverlay(view: self)
        FirestoreFunction.updateBookInFirestore(bookDetail: detail, completion: { boolResponse in
            
            LoadingScreen.shared.hideOverlay(view: self)
            if boolResponse {
                self.showAlertDialog(message: "Update book detail success", action: { _ in
                    ConstantValue.refreshTime = nil
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                self.showAlertDialog(message: "Update book detail failed.", action: nil)
            }
        })
    }
    
    private func createNewBook(title: String, author: String, desc: String, image: String, date: String) {
        LoadingScreen.shared.showOverlay(view: self)
        FirestoreFunction.createBookInFirestore(title: title, author: author, desc: desc, image: image, date: date, completion: { boolResponse in
            
            LoadingScreen.shared.hideOverlay(view: self)
            if boolResponse {
                self.showAlertDialog(message: "Added new book success", action: { _ in
                    ConstantValue.refreshTime = nil
                    self.navigationController?.popViewController(animated: true)
                })
            } else {
                self.showAlertDialog(message: "Create new book failed.", action: nil)
            }
        })
    }
    
    private func showAlertDialog(message: String, action: ((UIAlertAction) -> Void)?) {
        let action = UIAlertAction(title: "OK", style: .default, handler: action)

        showAlertController(message: message, alertActions: [action])
    }
    
    // MARK: - Objc func
    
    @objc func coverImageViewAction() {
        imageErrorMsgLabel.isHidden = true
        hideKeyboard()
        
        let action1 = UIAlertAction(title: "Camera", style: .default, handler: {_ in
            self.takePhoto(decision: 1)
        })
        let action2 = UIAlertAction(title: "Photo Gallery", style: .default, handler: {_ in
            self.takePhoto(decision: 2)
        })
        let action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        showAlertDialog(style: .actionSheet, title: nil, message: "Select image from", alertActions: [action1, action2, action3])
    }
    
    // MARK: - IBAction
    
    @IBAction private func editOrSaveButtonAction() {
        hideKeyboard()
        if isEditingBook {
            // save action
            validateTextField()
        } else {
            // edit action
            isEditingBook = true
            updateRightBarButtonText()
            setUserInteraction()
            
            nameTextField.becomeFirstResponder()
        }
    }
}

// MARK: - UITextFieldDelegate

extension BookDetailsViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == nameTextField {
            authorTextField.becomeFirstResponder()
        } else if textField == authorTextField {
            descTextView.becomeFirstResponder()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameTextField {
            nameErrorMsgLabel.isHidden = true
        } else if textField == authorTextField {
            authorErrorMsgLabel.isHidden = true
        }
    }
}

// MARK: - UITextViewDelegate

extension BookDetailsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        descErrorMsgLabel.isHidden = true
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "About this book"
            textView.textColor = UIColor.lightGray
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let maxLength = 200
        
        guard let characterCount = textView.text?.count else {
              return false
        }
        
        return characterCount < maxLength || text == ""
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension BookDetailsViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    private func takePhoto(decision: Int) {
        imagePicker =  UIImagePickerController()
        imagePicker.delegate = self
        if decision == 1 {
            let cameraMediaType = AVMediaType.video
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)

            let action1 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let action2 = UIAlertAction(title: "Go to Settings", style: .default, handler: {_ in
                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
            })

            switch cameraAuthorizationStatus {
            case .denied, .restricted:
                self.showAlertController(message: "Please turn on the camera permission at settings.", alertActions: [action1, action2])
                break
            case .authorized:
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true, completion: nil)
                break
            case .notDetermined:
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (choice) in
                    if choice {
                        Util.runInMainThread {
                            self.imagePicker.sourceType = .camera
                            self.present(self.imagePicker, animated: true, completion: nil)
                        }
                    } else {
                        self.showAlertController(message: "Please turn on the camera permission at settings.", alertActions: [action1, action2])
                    }
                })
            default:
                break
            }

        } else {
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.modalPresentationStyle = .fullScreen
            self.present(self.imagePicker, animated: true, completion: nil)
        }
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imagePicker.dismiss(animated: true, completion: nil)
        
        isCapture = true
        
        if let captureImage = info[.originalImage] as? UIImage,
            let rotatedImage = captureImage.fixedOrientation(),
            let tempData = rotatedImage.jpegData(compressionQuality: 0.0) {

            base64ImageString = tempData.base64EncodedString()
            coverImageView.image = UIImage(data: tempData)
        }
    }
}

// MARK: - CustomKeyboardDelegate

extension BookDetailsViewController: CustomKeyboardDelegate {
    func keyboardWillShow(keyboardEndFrame: CGRect, scrollView: UIScrollView) {}
    
    func keyboardWillHide(keyboardEndFrame: CGRect, scrollView: UIScrollView) {}
}
