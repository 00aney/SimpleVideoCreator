//
//  FirestoreService.swift
//  SimpleVideoCreator
//
//  Created by Ted Kim on 2019-01-27.
//  Copyright © 2019 Ted Kim. All rights reserved.
//

import Foundation

import Firebase
import FirebaseFirestore


enum FirestoreCollectionReference: String {
  case videos
}


enum AppError: Error {
  case encodingError
  case firestoreError
}


class FirestoreService {
  
  private init() {}
  static let shared = FirestoreService()

 
  func configure() {
    FirebaseApp.configure()
  }
  
  private func reference(to collectionReference: FirestoreCollectionReference) -> CollectionReference {
    return Firestore.firestore().collection(collectionReference.rawValue)
  }
  
  func create<T: Encodable>(
    for encodableObject: T,
    in collectionReference: FirestoreCollectionReference,
    completion: @escaping (_ id: String?, _ error: Error?) -> Void
  ) {
    do {
      let data = try encodableObject.toDictinary(excluding: ["id"])
      reference(to: collectionReference).addDocument(data: data)
        .getDocument { (snapshot, error) in
          completion(snapshot?.documentID, error)
      }
    } catch {
      completion(nil, error)
    }
  }
  
  func get<T: Decodable>(
    from collectionReference: FirestoreCollectionReference,
    returning objectType: T.Type,
    id: String,
    completion: @escaping (T?, _ error: Error?) -> Void
  ) {
    reference(to: .videos).document(id).getDocument{ (document, error) in
      guard let document = document else { return }
      do {
        let object = try document.decode(as: objectType, includingID: true)
        completion(object, nil)
      } catch {
        completion(nil, error)
      }
    }
  }
  

  func read<T: Decodable>(
    from collectionReference: FirestoreCollectionReference,
    returning objectType: T.Type,
    completion: @escaping ([T]?, _ error: Error?) -> Void
  ) {
    reference(to: .videos).addSnapshotListener { (snapshot, error) in
      guard let snapshot = snapshot else { return }
      do {
        var objects = [T]()
        for document in snapshot.documents {
          let object = try document.decode(as: objectType, includingID: true)
          objects.append(object)
        }
        completion(objects, nil)
      } catch {
        completion(nil, error)
      }
    }
  }

  func update() {
    // TODO: firestore update
  }
  
  func delete() {
    // TODO: firestore delete
  }
  
}
