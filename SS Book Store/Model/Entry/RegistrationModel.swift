//
//  RegistrationModel.swift
//  SS Book Store
//
//  Created by Soft Space User on 02/07/2021.
//

import Foundation

class RegistrationModel {
    static func registerUser(username: String, password: String, completion: @escaping ((_ callbackObject : RegistrationRespModel) -> ())) {
        
        var respModel = RegistrationRespModel()
        // check username existance first
        
        FirestoreFunction.checkUsernameExistance(username: username, completion: { boolResponse in
            if boolResponse {
                // register user if no duplicate username
                FirestoreFunction.registerUserToFirestore(username: username, password: password, completion: { boolResult in
                    
                    respModel.isSuccess = boolResult
                    if boolResult {
                        respModel.message = "Succcessfully registered"
                    } else {
                        respModel.message = "Registration failed"
                    }
                    completion(respModel)
                })
            } else {
                respModel.message = "Username is in used"
                completion(respModel)
            }
        })
    }
}
