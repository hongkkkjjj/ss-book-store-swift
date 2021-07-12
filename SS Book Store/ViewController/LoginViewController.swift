//
//  LoginViewController.swift
//  SS Book Store
//
//  Created by Soft Space User on 30/06/2021.
//

import UIKit

class LoginViewController: UIViewController {
    // MARK: - IBOutlet
    
    @IBOutlet private weak var mainScrollView: UIScrollView!
    @IBOutlet private weak var loginImageView: UIImageView!
    @IBOutlet private weak var usernameTextField: UITextField!
    @IBOutlet private weak var usernameErrorMsgLabel: UILabel!
    @IBOutlet private weak var passwordTextField: UITextField!
    @IBOutlet private weak var passwordErrorMsgLabel: UILabel!
    @IBOutlet private weak var loginButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    
    // MARK: - Override func

    override func viewDidLoad() {
        super.viewDidLoad()

        addKeyboardDisplayNotifications(scrollView: mainScrollView, delegate: self)
        enableHideKeyboardByTappingBackground(cancelsTouchesInView: false)
        addDelegateToTextField()
        setupView()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryboardSegue.loginToMain {
            if let navVC = segue.destination as? UINavigationController,
               let bookListVC = navVC.topViewController as? BookListViewController {
                bookListVC.fromlogin = true
            }
        }
    }
    
    // MARK: - Private func
    
    private func setupView() {
        loginButton.layer.cornerRadius = 10
        usernameErrorMsgLabel.isHidden = true
        passwordErrorMsgLabel.isHidden = true
    }
    
    private func addDelegateToTextField() {
        usernameTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    private func validateLoginTextField() {
        guard let username = usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !username.isEmpty else {
            usernameErrorMsgLabel.text = "Username cannot be empty"
            usernameErrorMsgLabel.isHidden = false
            return
        }
        
        guard let password = passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !password.isEmpty else {
            passwordErrorMsgLabel.text = "Password cannot be empty"
            passwordErrorMsgLabel.isHidden = false
            return
        }
        
        performUserLogin(username: username, password: password)
    }
    
    private func performUserLogin(username: String, password: String) {
        LoadingScreen.shared.showOverlay(view: self)
        
        FirestoreFunction.loginUserWithFirestore(username: username, password: password, completion: { boolResponse in
            
            LoadingScreen.shared.hideOverlay(view: self)
            if boolResponse {
                UserDefaultUtil.isUserLogin = true
                self.usernameErrorMsgLabel.isHidden = true
                self.passwordErrorMsgLabel.isHidden = true
                self.loginToMain()
            } else {
                self.usernameErrorMsgLabel.text = "Username or password is not valid"
                self.passwordErrorMsgLabel.text = "Username or password is not valid"
                self.usernameErrorMsgLabel.isHidden = false
                self.passwordErrorMsgLabel.isHidden = false
            }
        })
    }
    
    private func loginToMain() {
        self.performSegue(withIdentifier: StoryboardSegue.loginToMain, sender: nil)
    }
    
    // MARK: - IBAction
    
    @IBAction private func loginButtonAction() {
        validateLoginTextField()
    }
    
    @IBAction private func registerButtonAction(_ sender: Any) {
        self.performSegue(withIdentifier: StoryboardSegue.loginToRegister, sender: nil)
    }
}

extension LoginViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else if textField == passwordTextField {
            hideKeyboard()
        }
        
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == usernameTextField {
            usernameErrorMsgLabel.isHidden = true
        } else if textField == passwordTextField {
            passwordErrorMsgLabel.isHidden = true
        }
    }
}

extension LoginViewController: CustomKeyboardDelegate {
    func keyboardWillShow(keyboardEndFrame: CGRect, scrollView: UIScrollView) {}
    
    func keyboardWillHide(keyboardEndFrame: CGRect, scrollView: UIScrollView) {}
}
