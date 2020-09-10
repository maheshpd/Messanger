//
//  DatabaseManager.swift
//  Messanger
//
//  Created by Mahesh Prasad on 02/08/20.
//  Copyright © 2020 CreatesApp. All rights reserved.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
    static func safeEmail(emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}

//MARK: Account Management
extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping((Bool) -> Void)) {
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value) { (snapshot) in
            
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            
            completion(true)
            
        }
        
    }
    
    /// Insert new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping(Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name":user.firstName,
            "last_name":user.lastname
        ], withCompletionBlock: {error, _ in
            guard error == nil else {
                print("failed to write to database")
                completion(false)
                return
            }
            
            /*
             
             
             */
            
            self.database.child("users").observeSingleEvent(of: .value) { (snapshot) in
                
                if var usersCollection = snapshot.value as? [[String: String]] {
                    //append to user dictionary
                    
                    let newElement = [
                        "name": user.firstName + " "+user.lastname,
                        "email":user.safeEmail
                    ]
                    
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                    
                    
                }
                else {
                    //create that array
                    let newCollection: [[String: String]] = [
                        ["name": user.firstName + " "+user.lastname,
                         "email":user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                        
                    })
                }
                
            }
            
            
            
            completion(true)
        })
    }
    
    public func getAllUsers(completion: @escaping(Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
            
        }
        
    }
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    
    
    
}

struct ChatAppUser {
    let firstName: String
    let lastname: String
    let emailAddress: String
    
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        return safeEmail
    }
    
    var profilePictureFileName: String {
        //mahesh-gmail.com_profile_picture.png
        return "\(safeEmail)_profile_picture.png"
    }
    
}
