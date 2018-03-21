//
//  Users.swift
//  Lifer
//
//  Created by Mauricio Cabreira on 24/02/18.
//  Copyright © 2018 Mauricio Cabreira. All rights reserved.
//



import Foundation
import Firebase



struct Users {
   var key: String
  var email: String
  var name: String
  var lastName: String
  var gender: String
  var age: String
  var totalScore: String
  var startDate: String
  var startWeight: String
  var finalWeight: String
  var channelId: String
  var lastWeight: String
  var ref: DatabaseReference?

  
  init(email: String, name: String, lastName: String, gender: String, age: String, totalScore: String, startDate: String, startWeight: String, finalWeight: String, channelId: String, lastWeight: String,  key: String = "") {
     self.key = key
    self.email = email
    self.name = name
    self.lastName = lastName
    self.gender = gender
    self.age = age
    self.totalScore = totalScore
    self.startDate = startDate
    self.startWeight = startWeight
    self.finalWeight = finalWeight
    self.channelId = channelId
    self.lastWeight = lastWeight
     self.ref = nil
  }
  
  init(snapshot: DataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    
    email = snapshotValue["email"] as! String
    name = snapshotValue["name"] as! String
    lastName = snapshotValue["lastName"] as! String
    gender = snapshotValue["gender"] as! String
    age = snapshotValue["age"] as! String
    totalScore = snapshotValue["totalScore"] as! String
    startDate = snapshotValue["startDate"] as! String
    startWeight = snapshotValue["startWeight"] as! String
    finalWeight = snapshotValue["finalWeight"] as! String
    channelId = snapshotValue["channelId"] as! String
    lastWeight = snapshotValue["lastWeight"] as! String
    ref = snapshot.ref
  }
  
  func toAnyObject() -> Any {
    return [
      "email": email,
      "name": name,
      "lastName": lastName,
      "gender": gender,
      "age": age,
      "totalScore": totalScore,
      "startDate": startDate,
      "startWeight": startWeight,
      "finalWeight": finalWeight,
      "channelId": channelId,
      "lastWeight": lastWeight
    ]
  }
  
}





