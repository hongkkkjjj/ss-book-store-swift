//
//  FirestoreFunction.swift
//  SS Book Store
//
//  Created by Soft Space User on 03/07/2021.
//

import Foundation
import Firebase

class FirestoreFunction {
    private static let db = Firestore.firestore()
    
    static func loginUserWithFirestore(username: String, password: String, completion: @escaping (_ callbackObject: Bool) -> ()) {
        
        let userRef = db.collection("user")
        userRef.whereField("username", isEqualTo: username).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(false)
            } else {
                if let snapshot = querySnapshot {
                    if snapshot.documents.count == 1 {
                        let document = snapshot.documents[0]
                        
                        if document["password"] as? String == password {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    } else {
                        completion(false)
                    }
                } else {
                    completion(false)
                }
            }
        }
    }
    
    static func getBookDataFromFirestore(completion: @escaping ((_ callbackObject : [BookDetails]) -> ())) {
        var bookList: [BookDetails] = []
        
        db.collection("book").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                
                completion(bookList)
            } else {
                for document in querySnapshot!.documents {
                    let data = document.data()
                    var bookDetail = BookDetails()
                    bookDetail.firestoreId = document.documentID
                    bookDetail.bookTitle = data["title"] as? String ?? ""
                    bookDetail.authorName = data["author"] as? String ?? ""
                    bookDetail.strDate = data["date"] as? String ?? ""
                    bookDetail.description = data["desc"] as? String ?? ""
                    bookDetail.bookImage = data["image"] as? String ?? ""
                    if !bookDetail.strDate.isEmpty {
                        bookDetail.date = Util.convertToDate(bookDetail.strDate, fromFormat: "dd MMM yy")
                    }
                    bookList.append(bookDetail)
                }
                
                completion(bookList)
            }
        }
    }
    
    static func checkUsernameExistance(username: String, completion: @escaping ((_ callbackObject : Bool) -> ())) {
        let userRef = db.collection("user")
        userRef.whereField("username", isEqualTo: username).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
                completion(false)
            } else {
                if let snapshot = querySnapshot,
                   snapshot.documents.count == 0 {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
    }
    
    static func registerUserToFirestore(username: String, password: String, completion: @escaping ((_ callbackObject : Bool) -> ())) {
        db.collection("user").document(username).setData([
            "username": username,
            "password": password,
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
            } else {
                print("Document successfully written!")
                completion(true)
            }
        }
    }
    
    static func createBookInFirestore(title: String, author: String, desc: String, image: String, date: String, completion: @escaping ((_ callbackObject : Bool) -> ())) {
        db.collection("book").addDocument(data: [
            "title": title,
            "author": author,
            "desc": desc,
            "date": date,
            "image": image
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    static func updateBookInFirestore(bookDetail: BookDetails, completion: @escaping ((_ callbackObject : Bool) -> ())) {
        db.collection("book").document(bookDetail.firestoreId).setData([
            "title": bookDetail.bookTitle,
            "author": bookDetail.authorName,
            "desc": bookDetail.description,
            "date": bookDetail.strDate,
            "image": bookDetail.bookImage
        ]) { err in
            if let err = err {
                print("Error writing document: \(err)")
                completion(false)
            } else {
                print("Document successfully written!")
                completion(true)
            }
        }
    }
    
    static func deleteBookInFirestore(bookId: String, completion: @escaping ((_ callbackObject : Bool) -> ())) {
        db.collection("book").document(bookId).delete() { err in
            if err != nil {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
