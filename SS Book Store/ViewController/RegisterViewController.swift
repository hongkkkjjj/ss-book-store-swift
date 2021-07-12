//
//  RegisterViewController.swift
//  SS Book Store
//
//  Created by Soft Space User on 01/07/2021.
//

import UIKit

class RegisterViewController: UIViewController {
    
    @IBOutlet private weak var mainScrollView: UIScrollView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var usernameLabel: UILabel!
    @IBOutlet private weak var passwordLabel: UILabel!
    @IBOutlet private weak var reenterPasswordLabel: UILabel!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var reenterPasswordTextField: UITextField!
    @IBOutlet private weak var usernameErrorMsgLabel: UILabel!
    @IBOutlet private weak var passwordErrorMsgLabel: UILabel!
    @IBOutlet private weak var reenterPasswordErrorMsgLabel: UILabel!
    @IBOutlet private weak var closeImageView: UIImageView!
    @IBOutlet private weak var registerButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardDisplayNotifications(scrollView: mainScrollView, delegate: self)
        enableHideKeyboardByTappingBackground(cancelsTouchesInView: false)
        addRegisterTextFieldDelegate()
        setupView()
    }
    
    // MARK: - Private func
    
    private func setupView() {
        registerButton.layer.borderWidth = 2
        registerButton.layer.borderColor = ColorUtil.lightGreen.cgColor
        registerButton.layer.cornerRadius = 12
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAlertController))
        closeImageView.addGestureRecognizer(tapGesture)
        
        usernameErrorMsgLabel.isHidden = true
        passwordErrorMsgLabel.isHidden = true
        reenterPasswordErrorMsgLabel.isHidden = true
    }
    
    private func addRegisterTextFieldDelegate() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        reenterPasswordTextField.delegate = self
    }
    
    private func validateTextField() {
        usernameErrorMsgLabel.isHidden = true
        passwordErrorMsgLabel.isHidden = true
        reenterPasswordErrorMsgLabel.isHidden = true
        
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            usernameErrorMsgLabel.text = "Username cannot be empty"
            usernameErrorMsgLabel.isHidden = false
            return
        }
        
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            passwordErrorMsgLabel.text = "Password cannot be empty"
            passwordErrorMsgLabel.isHidden = false
            return
        }
        
        guard let reenterPassword = reenterPasswordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            reenterPasswordErrorMsgLabel.text = "Reenter password cannot be empty"
            reenterPasswordErrorMsgLabel.isHidden = false
            return
        }
        
        guard password == reenterPassword else {
            passwordErrorMsgLabel.text = "Password and reenter password need to be same"
            reenterPasswordErrorMsgLabel.text = "Password and reenter password need to be same"
            passwordErrorMsgLabel.isHidden = false
            reenterPasswordErrorMsgLabel.isHidden = false
            return
        }
        
        registerUser(username: username, password: password)
    }
    
    private func registerUser(username: String, password: String) {
        LoadingScreen.shared.showOverlay(view: self)
        RegistrationModel.registerUser(username: username, password: password, completion: { registrationRespModel in
            LoadingScreen.shared.hideOverlay(view: self)
            if registrationRespModel.isSuccess {
                self.showAlertDialog(message: registrationRespModel.message, action: { _ in
                    self.dismiss(animated: true, completion: nil)
                })
            } else {
                self.showAlertDialog(message: registrationRespModel.message, action: nil)
            }
        })
    }
    
    private func showAlertDialog(message: String, action: ((UIAlertAction) -> Void)?) {
        let action = UIAlertAction(title: "OK", style: .default, handler: action)

        showAlertController(message: message, alertActions: [action])
    }
    
    // MARK: - Objc func
    
    @objc private func dismissAlertController() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction private func registerButtonAction() {
        validateTextField()
    }
}

extension RegisterViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            reenterPasswordTextField.becomeFirstResponder()
        } else if textField == reenterPasswordTextField {
            hideKeyboard()
        }
        
        return true
    }
}

extension RegisterViewController: CustomKeyboardDelegate {
    func keyboardWillShow(keyboardEndFrame: CGRect, scrollView: UIScrollView) {}
    
    func keyboardWillHide(keyboardEndFrame: CGRect, scrollView: UIScrollView) {}
}
