//
//  AppDelegate.swift
//  Lifer
//
//  Created by Mauricio Cabreira on 26/01/18.
//  Copyright © 2018 Mauricio Cabreira. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import UserNotifications
import SafariServices

//fileprivate let viewActionIdentifier = "VIEW_IDENTIFIER"
//fileprivate let newsCategoryIdentifier = "NEWS_CATEGORY"


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  // Messages repository - to-do: add persistance
  var messages = [Message]()
  var user: User! //Firebase user
  var currentUserData: Users! //Datamodel information from current user
  var days = [Days]()  //Journey for the user
  var lastWeight: Double = 0
  var lastWeightDayIndex = 0
  let debug = false
  var userKey: String = ""
  var fcmUserPushNotificationToken = ""
 
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    // Override point for customization after application launch.
    
    if debug {
      createMockupMessages()
      createMockupDays()
      createMockupCurrentUserData()
    }
    
    // Override point for customization after application launch.
    // Sets background to a blank/empty image
    UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
    // Sets shadow (line below the bar) to a blank image
    UINavigationBar.appearance().shadowImage = UIImage()
    // Sets the translucent background color
    UINavigationBar.appearance().backgroundColor = .clear
    // Set translucent. (Default value is already true, so this can be removed if desired.)
    UINavigationBar.appearance().isTranslucent = true
    
    
    //debug
    //let userDefaults = UserDefaults.standard
    //userDefaults.set("Fr9TkezIoGeR0cejBAMwBeStdir2", forKey: "userKey")
    //userDefaults.synchronize()
    
    //Retrieve userKey, if any
    if let uk = UserDefaults.standard.string(forKey: "userKey") {
      userKey = uk
      print("AppDelegate.swift: userkey: \(userKey)")
    }
    
    //APN setup
    UNUserNotificationCenter.current().delegate = self
    
    //Firebase setup
    FirebaseApp.configure()
    Database.database().isPersistenceEnabled = true // This set persistance. do I need the swift persistance and DB model then??? dont think so. just fb shall suffice since it has persistance as well. and works offline.
    
    
    //Firebase Messaging setup (MessageVC)
    Messaging.messaging().delegate = self
    
    // This call the famous Enable notifications window.
    registerForPushNotifications()
    
    // Check if launched from notification
    //debug: aqui 21.3.2018, estava. se parar de fncionar, voltar.
//    if let notification = launchOptions?[.remoteNotification] as? [String: AnyObject] {
//      let aps = notification["aps"] as! [String: AnyObject]
//      _ = NewsItem.makeNewsItem(aps)
//      (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
//    }
    

     return true
  }
  
  
  
  func registerForPushNotifications() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
      (granted, error) in
      print("Permission granted: \(granted)")
      
      guard granted else {
        return
        
      }
      //DEBUG: PUSH funciona. depois comentei isso dia 21.3, se parar de funcionar, voltar e ver.
//      let viewAction = UNNotificationAction(identifier: viewActionIdentifier,
//                                            title: "View",
//                                            options: [.foreground])
//
//      let newsCategory = UNNotificationCategory(identifier: newsCategoryIdentifier,
//                                                actions: [viewAction],
//                                                intentIdentifiers: [],
//                                                options: [])
//      UNUserNotificationCenter.current().setNotificationCategories([newsCategory])
      self.getNotificationSettings()
    }
  }
  
  func getNotificationSettings() {
    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
      print("Notification settings: \(settings)")
      guard settings.authorizationStatus == .authorized else { return }
      UIApplication.shared.registerForRemoteNotifications()
    }
  }
  

  
  // Called if the registration was successful
  func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    let tokenParts = deviceToken.map { data -> String in
      return String(format: "%02.2hhx", data)
    }
    
    let token = tokenParts.joined()
    print("Device Token: \(token)")
  }
  
  // Called if the registration failed
  func application(_ application: UIApplication,
                   didFailToRegisterForRemoteNotificationsWithError error: Error) {
    print("Failed to register: \(error)")
  }
  
  
  var applicationStateString: String {
    if UIApplication.shared.applicationState == .active {
      return "active"
    } else if UIApplication.shared.applicationState == .background {
      return "background"
    }else {
      return "inactive"
    }
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    self.saveContext()
  }
  
  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "Lifer")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  
  
  
  
}

extension AppDelegate : MessagingDelegate {
  func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
    NSLog("[RemoteNotification] didRefreshRegistrationToken: \(fcmToken)")
  }
  
  
  func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
    
    let token = Messaging.messaging().fcmToken
    print("FCM token: \(token ?? "")")
    fcmUserPushNotificationToken = token!
    
  }
  
  
  // iOS9, called when presenting notification in foreground
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
    NSLog("[RemoteNotification] applicationState: \(applicationStateString) didReceiveRemoteNotification for iOS9: \(userInfo)")
    if UIApplication.shared.applicationState == .active {
      //TODO: Handle foreground notification
    } else {
      //TODO: Handle background notification
    }
    
    if let messageID = userInfo[fcmUserPushNotificationToken] {
      print("Message ID: \(messageID)")
    }
    
    // Print full message.
    print(userInfo)
    
   
  }
  
  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                   fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
    // If you are receiving a notification message while your app is in the background,
    // this callback will not be fired till the user taps on the notification launching the application.
    // TODO: Handle data of notification
    
    // With swizzling disabled you must let Messaging know about the message, for Analytics
    // Messaging.messaging().appDidReceiveMessage(userInfo)
    
    // Print message ID.
    if let messageID = userInfo[fcmUserPushNotificationToken] {
      print("Message ID: \(messageID)")
    }
    
    // Print full message.
    print(userInfo)
    
    completionHandler(UIBackgroundFetchResult.newData)
  }
  
}

extension AppDelegate: UNUserNotificationCenterDelegate {
  
  func userNotificationCenter(_ center: UNUserNotificationCenter,
                              didReceive response: UNNotificationResponse,
                              withCompletionHandler completionHandler: @escaping () -> Void) {
  
    
    
    // Aqui é o exemplo para chamar o view controller e abrir o site. Mudar para o view controller correto se usar isso um dia.
//    let userInfo = response.notification.request.content.userInfo
//    let aps = userInfo["aps"] as! [String: AnyObject]
//    
//  
//    if let newsItem = NewsItem.makeNewsItem(aps) {
//      (window?.rootViewController as? UITabBarController)?.selectedIndex = 1
//      
//      
//      if response.actionIdentifier == viewActionIdentifier,
//        let url = URL(string: newsItem.link) {
//        let safari = SFSafariViewController(url: url)
//        window?.rootViewController?.present(safari, animated: true, completion: nil)
//      }
// 
//    }
    
    
    
    completionHandler()
  }
}

extension AppDelegate {
  
  func createMockupMessages() {
    
    let messagesMockup = [
      Message(messageContent: "Mensagem #1 do bot", sender: Agent.bot),
      Message(messageContent: "Mensagem #1 do user", sender: Agent.user),
      Message(messageContent: "Mensagem #2 do bot", sender: Agent.bot),
      Message(messageContent: "Mensagem #2 do user", sender: Agent.user),
      Message(messageContent: "Mensagem #3 do bot", sender: Agent.bot),
      Message(messageContent: "Mensagem #4 do bot", sender: Agent.bot)
    ]
    for message in messagesMockup {
      self.messages.append(message)
    }
  }
  
  func createMockupCurrentUserData() {
    let userMockup = Users(email: "m@gmail.com", name: "mauricio", lastName: "", gender: "", age: "42", totalScore: "100", startDate: "25022018", startWeight: "69", finalWeight: "0", channelId: "", lastWeight: "", key: "KEY_DEBUG")
    currentUserData = userMockup
  }
  
  func createMockupDays() {
    let day1mockup = Days(day: "Day 1", dayIndex: 0, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "69", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU")
    
     //init(day: String, scoreAppOpened: Bool, scoreExercized: Bool, scoreAteHealthy: Bool, weight: String, isItWeekDivider: Bool, email: String, completed: Bool, key: String = "")
    let daysMockup = [
      Days(day: "Day 1", dayIndex: 0, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "69", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 2", dayIndex: 1, scoreAppOpened: true, scoreExercized: true, scoreAteHealthy: true, weight: "70", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 3", dayIndex: 2, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: true, weight: "71", weightTrendisUp: true, isItWeekDivider: true, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 4", dayIndex: 3, scoreAppOpened: false, scoreExercized: true, scoreAteHealthy: false, weight: "72.1", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 5", dayIndex: 4, scoreAppOpened: false, scoreExercized: true, scoreAteHealthy: false, weight: "73", weightTrendisUp: true, isItWeekDivider: true, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 6", dayIndex: 5, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "74", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 7", dayIndex: 6, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "75", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 8", dayIndex: 7, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "76", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 9", dayIndex: 8, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "77", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 10", dayIndex: 9, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "78", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 11", dayIndex: 10, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "79", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 12", dayIndex: 11, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "80", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 13", dayIndex: 12, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "81", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 14", dayIndex: 13, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "82", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 15", dayIndex: 14, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "81", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 16", dayIndex: 15, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "80", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 17", dayIndex: 16, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "79", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 18", dayIndex: 17, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "78", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 19", dayIndex: 18, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "77", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 20", dayIndex: 19, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "76", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 21", dayIndex: 20, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "75", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 22", dayIndex: 21, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "74", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 23", dayIndex: 22, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "73", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 24", dayIndex: 23, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "74", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 25", dayIndex: 24, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "73", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 26", dayIndex: 25, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "74", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 27", dayIndex: 26, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "73.9", weightTrendisUp: false, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU"),
      Days(day: "Day 28", dayIndex: 27, scoreAppOpened: false, scoreExercized: false, scoreAteHealthy: false, weight: "74", weightTrendisUp: true, isItWeekDivider: false, email: "mauricio@gmail.com", completed: false, key: "KEY_MAU")
    ]
    
    for day in daysMockup {
      //days.append(day)
      days.insert(day, at: 0)
    }
    
  }
  
  
  
}

