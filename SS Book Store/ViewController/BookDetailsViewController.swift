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
    @IBOutlet private weak var nameTextView: UITextView!
    @IBOutlet private weak var nameErrorMsgLabel: UILabel!
    @IBOutlet private weak var authorTextView: UITextView!
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
            nameTextView.textColor = .lightGray
            authorTextView.textColor = .lightGray
            descTextView.textColor = .lightGray
            editOrSaveButton.title = "Done"
            coverImageView.layer.borderWidth = 2
        }
        
        addBorderToView(view: nameView)
        addBorderToView(view: authorView)
        addBorderToView(view: descView)
        
        nameTextView.delegate = self
        authorTextView.delegate = self
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
        nameTextView.text = detail.bookTitle
        authorTextView.text = detail.authorName
        descTextView.text = detail.description
        coverImageView.image = Util.convertBase64StringToImage(imageBase64String: detail.bookImage)
        base64ImageString = detail.bookImage
        
        setUserInteraction()
        nameTextView.textColor = .black
        authorTextView.textColor = .black
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
        nameTextView.isUserInteractionEnabled = isEditingBook
        authorTextView.isUserInteractionEnabled = isEditingBook
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
        
        guard let title = nameTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !title.isEmpty else {
            nameErrorMsgLabel.text = "Book name is required"
            nameErrorMsgLabel.isHidden = false
            return
        }
        
        guard let author = authorTextView.text?.trimmingCharacters(in: .whitespacesAndNewlines), !author.isEmpty else {
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
        
        let alertController = UIAlertController(title: nil, message: "Select image from", preferredStyle: .actionSheet)
        
        let action1 = UIAlertAction(title: "Camera", style: .default, handler: {_ in
            self.takePhoto(decision: 1)
        })
        let action2 = UIAlertAction(title: "Photo Gallery", style: .default, handler: {_ in
            self.takePhoto(decision: 2)
        })
        let action3 = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        alertController.addAction(action3)
        
        if let popoverPresentationController = alertController.popoverPresentationController {
            popoverPresentationController.sourceView = self.view
            viewDidLayoutSubviews()
            popoverPresentationController.sourceRect = CGRect(x: coverImageView.frame.maxX, y: coverImageView.frame.midY + 30, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = .left
        }
        
        self.present(alertController, animated: true, completion: nil)
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
            
            nameTextView.becomeFirstResponder()
        }
    }
}

// MARK: - UITextViewDelegate

extension BookDetailsViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        nameErrorMsgLabel.isHidden = true
        authorErrorMsgLabel.isHidden = true
        descErrorMsgLabel.isHidden = true
        
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            
            if textView == nameTextView {
                textView.text = "Book name"
            } else if textView == authorTextView {
                textView.text = "Author name"
            } else if textView == descTextView {
                textView.text = "About this book"
            }
            
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
