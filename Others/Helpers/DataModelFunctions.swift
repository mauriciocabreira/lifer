//
//  DataModelFunctions.swift
//  Lifer
//
//  Created by Mauricio Cabreira on 08/02/18.
//  Copyright © 2018 Mauricio Cabreira. All rights reserved.
//

/*
import Foundation
import CoreData

class DataModelFunctions {
  
  
  var sharedContext = CoreDataStack.sharedInstance().context
  var userLoggedIn = false
  var userData: User?
  var loggedWeights: [Weight] = []
  var scores: [Score] = []
  var currentDay: Int16 = 0
  var programStartDate: NSDate?
  
  class func sharedInstance() -> DataModelFunctions {
    struct Singleton {
      static var sharedInstance = DataModelFunctions()
    }
    return Singleton.sharedInstance
  }
  
  
  
  // MARK: Build the fetch request controller, which will fetch data. it looks for a specific Entity or bring all entities stored in core data
  func createUserFetchedResultsController() -> NSFetchedResultsController<User>? {
    
    let fetchRequest = NSFetchRequest<User>(entityName: "User")
    fetchRequest.sortDescriptors = []
    
    
    let userFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    userFetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
//    userFetchedResultsController.delegate = self
    //ATENCAO o downcast acima foi adicionado. testar se retorna usuario.
    return userFetchedResultsController
  }
  
  // MARK: Build the fetch request controller, which will fetch data. it looks for a specific Entity or bring all entities stored in core data
  func createScoreFetchedResultsController() -> NSFetchedResultsController<Score>? {
    
    let fetchRequest = NSFetchRequest<Score>(entityName: "Score")
    fetchRequest.sortDescriptors = []
    
    
    let scoreFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    
    scoreFetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
//    scoreFetchedResultsController.delegate = self
    
    return scoreFetchedResultsController
  }
  
  // MARK: Build the fetch request controller, which will fetch data. it looks for a specific Entity or bring all entities stored in core data
  func createWeightFetchedResultsController() -> NSFetchedResultsController<Weight>? {
    
    let fetchRequest = NSFetchRequest<Weight>(entityName: "Weight")
    fetchRequest.sortDescriptors = []
    
    
    let weightFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.sharedContext, sectionNameKeyPath: nil, cacheName: nil)
    weightFetchedResultsController.delegate = self as? NSFetchedResultsControllerDelegate
//    weightFetchedResultsController.delegate = self
    
    return weightFetchedResultsController
  }
  
  
  
  
  // MARK: User fetch request.
  func performUserFetchRequest(_ userFetchedResultsController: NSFetchedResultsController<User>?) {
    
    if let userFetchedResultsController = userFetchedResultsController {
      do {
        try userFetchedResultsController.performFetch()
      } catch let userFetchError as NSError {
        print("Error performing fetch user: \(userFetchError)")
      }
    }
  }
  
  
  // MARK: Score fetch request.
  func performScoreFetchRequest(_ scoreFetchedResultsController: NSFetchedResultsController<Score>?) {
    
    if let scoreFetchedResultsController = scoreFetchedResultsController {
      do {
        try scoreFetchedResultsController.performFetch()
      } catch let scoreFetchError as NSError {
        print("Error performing fetch score: \(scoreFetchError)")
      }
    }
  }
  
  // MARK: Weight fetch request.
  func performWeightFetchRequest(_ weightFetchedResultsController: NSFetchedResultsController<Weight>?) {
    
    if let weightFetchedResultsController = weightFetchedResultsController {
      do {
        try weightFetchedResultsController.performFetch()
      } catch let weightFetchError as NSError {
        print("Error performing fetch weight: \(weightFetchError)")
      }
    }
  }
  
  
  func createUser(_ name: String, _ lastName: String, _ age: Int16, _ gender: Int16, _ email: String, _ weight: Double) {
    
    // Add user to core data
    let userCD = User(context: sharedContext)
    userCD.name = name
    userCD.lastName = lastName
    userCD.age = age
    userCD.gender = gender
    userCD.email = email
    userCD.startDate = NSDate.init()
    userCD.startDayWeek = 0
    userCD.programDuration = 28 - userCD.startDayWeek
    
    performUIUpdatesOnMain {
      CoreDataStack.sharedInstance().save()
    }
    
    getUserData()
    //Add initial weight
    logWeight(weight)
    logScore(true, true, true)
    userLoggedIn = true
    
    getScoreData()
    getWeightData()
    
  }
  
  func logScore(_ appOpened: Bool, _ exercised: Bool, _ ateHealthy: Bool) {
    var score: Int16 = 0
    
    let newScore = Score(context: sharedContext)
    newScore.appOpened = appOpened
    newScore.exercised = exercised
    newScore.ateHealthy = ateHealthy
    newScore.day = currentDay
    
    if appOpened { score = score + 1}
    if exercised { score = score + 1}
    if ateHealthy { score = score + 1}
    
    newScore.score = score
    newScore.user = userData
    
    performUIUpdatesOnMain {
      CoreDataStack.sharedInstance().save()
    }
  }
  
  func logWeight(_ weight: Double) {
    
    let newWeight = Weight(context: sharedContext)
    newWeight.weight = weight
    newWeight.user = userData
    newWeight.date = NSDate.init()
    
    let weekDay = getDayInTheWeek(newWeight.date!)
    newWeight.dayInTheWeek =  weekDay.rawValue as Int16
    
    performUIUpdatesOnMain {
      CoreDataStack.sharedInstance().save()
    }
    
  }
  
  func getDayInTheWeek(_ date: NSDate) -> WeekDays {
    //TODO
    return WeekDays.mon
  }
  
  
  func getUserData() {
    if let userFetchedResultsController = createUserFetchedResultsController() {
      performUserFetchRequest(userFetchedResultsController)
      
      
      
      if let users = userFetchedResultsController.fetchedObjects {
        
        
        print("Total users: \(users.count)")
//
//        var i = 1
//
//        for user in users {
//          print("User \(i) :\(user.name)  \(user.lastName) \(user.age) \(user.email) \(user.gender) \(user.programDuration) \(user.startDate) \(user.programDuration)" )
//          i = i + 1
//
//        }
//
        //LoggedUserPin.sharedInstance.user = users[0]
        userData =  users[0]
        
        // print("User data: \(user?.name)  \(user?.lastName) \(user?.age) \(user?.email) \(user?.gender) \(user?.programDuration) \(user?.startDate) \(user?.programDuration) ")
        
        
      }
    }
  }
  
  func getScoreData()  {
    if let scoreFetchedResultsController = createScoreFetchedResultsController() {
      performScoreFetchRequest(scoreFetchedResultsController)
      
      if let scores = scoreFetchedResultsController.fetchedObjects {
              print("Total scores: \(scores.count)")
        self.scores =  scores
      }
    }
    
  }
  
  func getWeightData() {
    if let weightFetchedResultsController = createWeightFetchedResultsController() {
      performWeightFetchRequest(weightFetchedResultsController)
      
      if let weights = weightFetchedResultsController.fetchedObjects {
              print("Total weights: \(weights.count)")
        loggedWeights = weights
      }
    }
  }
  
  
}
 */
