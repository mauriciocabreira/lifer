//
//  LoginViewController.swift
//  Lifer
//
//  Created by Mauricio Cabreira 1/9/2018.
//  Copyright (c) 2018 Mauricio. All rights reserved.
//


import UIKit
import Firebase
import UserNotifications


class LoginViewController: UIViewController {
  
  
  
  // MARK: Constants
  let segueJourney = "LoginToJourney"
  let segueChat = "LoginToChat"
  let appDelegate = UIApplication.shared.delegate as! AppDelegate

  private var channelRefHandle: DatabaseHandle?
  private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")

  var users: [Users] = []
  
  var handle: AuthStateDidChangeListenerHandle?
  typealias DataClosure = (Data?, Error?) -> Void
  
  enum SignupStages: Int {
    case userClickedSignupFirstTime = 0,
    signupFieldsShown
  }
  
  var signupStages = SignupStages.userClickedSignupFirstTime
  
  
  enum SigninStages: Int {
    case userClickedSigninFirstTime = 0,
    signinFieldsShown
  }
  var signinStages = SigninStages.userClickedSigninFirstTime

  
  // MARK: Outlets
  
  @IBOutlet weak var textFieldLoginEmail: UITextField!
  @IBOutlet weak var textFieldLoginPassword: UITextField!
  @IBOutlet weak var signinButton: UIButton!
  @IBOutlet weak var signupButton: UIButton!
  @IBOutlet weak var signupIntructionLabel: UILabel!
  @IBOutlet weak var signinIntructionsLabel: UILabel!
  
  // MARK: Actions
  
  @IBAction func loginDidTouch(_ sender: AnyObject) {
    
    if signinStages == SigninStages.userClickedSigninFirstTime {
      signinIntructionsLabel.isHidden = false
      textFieldLoginEmail.isHidden = false
      textFieldLoginPassword.isHidden = false
      
      signupIntructionLabel.isHidden = true
      signupStages = SignupStages.userClickedSignupFirstTime
      signupButton.setTitle("Primeira vez? Clique aqui", for: .normal)
      
      
      signinStages = SigninStages.signinFieldsShown
      signinButton.setTitle("Entrar", for: .normal)
      return
    } else {
      if signinStages == SigninStages.signinFieldsShown {
        
        //debug
        textFieldLoginEmail.text = "mauricio2@runs.site"
        textFieldLoginPassword.text = "mmmmmm"
        
        let email = textFieldLoginEmail.text!
        let password = textFieldLoginPassword.text!
       
        
        
        
        if email == "" {
          self.showMessagePrompt("Campo email não pode estar vazio.")
          return
        }
        
        if password == "" {
          self.showMessagePrompt("Campo senha não pode estar vazio.")
          return
        }
        firebaseLogin(textFieldLoginEmail.text!, textFieldLoginPassword.text!)
        
      }
    }
  }
  
  
  @IBAction func signUpDidTouch(_ sender: AnyObject) {
    
    
    if signupStages == SignupStages.userClickedSignupFirstTime {
      signupIntructionLabel.isHidden = false
      textFieldLoginEmail.isHidden = false
      textFieldLoginPassword.isHidden = false
      signupStages = SignupStages.signupFieldsShown
      signupButton.setTitle("Começar", for: .normal)
      
      signinIntructionsLabel.isHidden = true
      signinStages = SigninStages.userClickedSigninFirstTime
      signinButton.setTitle("Já é cadastrado? Clique aqui", for: .normal)
      
      
      return
      
    } else {
      if signupStages == SignupStages.signupFieldsShown {
        
        //debug
        let email = "mauricio2@runs.site"
        let password = "mmmmmm"
        
        //let email = textFieldLoginEmail.text!
        //let password = textFieldLoginPassword.text!
     
        if email == "" {
          self.showMessagePrompt("Campo email não pode estar vazio.")
          return
        }
        
        if password == "" {
          self.showMessagePrompt("Campo senha não pode estar vazio.")
          return
        }
        
        self.showSpinner {

          Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            
             self.hideSpinner {
              if let error = error {
                self.showMessagePrompt(error.localizedDescription)
                return
              }
              
              
              //Create the program. Executed only once, when user is created.
              let dateformatter = DateFormatter()
              dateformatter.dateFormat = "yyyyMMdd"
              
              let startDate = dateformatter.string(from: Date())
       
              let channelForUser = self.createChannel(user!.email!)  // create firebase channel id to store messages
              self.createUserData(user!.email!, "empty", "", "", "0", "0", startDate, "0", "0", channelForUser, "0", user!.uid)
              self.createDays()
              
              
              //Update global user variables used elsewhere
              self.appDelegate.userKey = (user?.uid)!
              let userDefaults = UserDefaults.standard
              userDefaults.set(user?.uid, forKey: "userKey")
              userDefaults.synchronize()
              
              self.retrieveUserData(user!) { (user, error) in
                if let error = error {
                  self.showMessagePrompt(error.localizedDescription)
                  return
                }
              }
            }
          }
        }
      }
      
    }
  }
  
  @IBAction func didRequestPasswordReset(_ sender: AnyObject) {
    showTextInputPrompt(withMessage: "Informe o email cadastrado:") { (userPressedOK, email) in
      if let email = email {
        self.showSpinner {
          Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            self.hideSpinner {
              if let error = error {
                self.showMessagePrompt(error.localizedDescription)
                return
              }
              self.showMessagePrompt("Link para resetar senha enviado para o seu email.")
            }
          }
        }
      }
    }
  }
  
  
  //MARK: Lifecycle
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
     configureLoginScreen()
    if appDelegate.debug {
      performUIUpdatesOnMain {
        self.performSegue(withIdentifier: self.segueJourney, sender: nil)
      }
    } else {
      Auth.auth().addStateDidChangeListener() { auth, user in
        if user != nil {
          self.appDelegate.userKey = (user?.uid)!
          let userDefaults = UserDefaults.standard
          userDefaults.set(user?.uid, forKey: "userKey")
          userDefaults.synchronize()
          
          self.retrieveUserData(user!) { (user, error) in
            if let error = error {
              self.showMessagePrompt(error.localizedDescription)
                return
            }
          }
        //If we add here the Days fetch data and the performSegue, it does not work, since it wont come back to this function. it needs to be called within the function(s). Segue and getDays are called from retrieveUserData
        } else {
          print("No user logged in")
        }
      }
    }
  }

  

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
   
    if !appDelegate.debug {
      handle = Auth.auth().addStateDidChangeListener { (auth, user) in

        self.appDelegate.user = user
      }
    }
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    if !appDelegate.debug {
      Auth.auth().removeStateDidChangeListener(handle!)
    }
  }

  //MARK: User and data management functions
  
  
  // Firebase user login
  func firebaseLogin(_ email: String, _ password: String) {
    
    if email == "" || password == "" {
      self.showMessagePrompt("Campo senha / email não podem estar vazios.")
      return
    }
    showSpinner {

      Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
        
        self.hideSpinner {
          if let error = error {
            self.showMessagePrompt(error.localizedDescription)
            return
          }
          
          //Update logged user in local persistance
          print("User signed in with success: \(user!.email!) User uid/key: \(user!.uid)")
          
          let userDefaults = UserDefaults.standard
          userDefaults.set(user?.uid, forKey: "userKey")
          userDefaults.synchronize()
          
          self.appDelegate.userKey = (user?.uid)!
          self.appDelegate.user = user
          
          self.retrieveUserData(user!) { (user, error) in
            if let error = error {
              self.showMessagePrompt(error.localizedDescription)
              return
            }
          }
  
        }
      }
    }
  }
  
  func createUserData(_ email: String, _ name: String, _ lastName: String, _ gender: String, _ age: String, _ totalScore: String, _ startDate: String, _ startWeight: String, _ finalWeight: String, _ channelId: String, _ lastWeight: String, _ key: String) {

    let refUsers = Database.database().reference(withPath: "users")
    let user = Users(email: email,
                     name: name,
                     lastName: lastName,
                     gender: gender,
                     age: age,
                     totalScore: totalScore,
                     startDate: startDate,
                     startWeight: startWeight,
                     finalWeight: finalWeight,
                     channelId: channelId,
                     lastWeight: lastWeight)

    let userRef = refUsers.child(key)
    userRef.setValue(user.toAnyObject())
    self.appDelegate.currentUserData = user
    

  }
  
  
  //MARK: Create FB channel to store chat messages. FB structure:
  //  https://lifer-mauricio.firebaseio.com/channels/channelId (which is connected to the user, since chat is with BOT + USER always)
  //                                                          /name (channel name - always the user email)
  //                                                          /typingIndicator (Bool)
  //                                                          /messages
  //                                                                  /messageId  (it is an unique ID)
  //                                                                        /senderId
  //                                                                        /senderName
  //                                                                        /text
  //                                                                  /messageId
  //                                                                        /senderId
  //                                                                        /senderName
  //                                                                        /text
  //                                                                ........
  func createChannel(_ email: String) -> String {
    let name = email
      let newChannelRef = channelRef.childByAutoId()
      let channelItem = [
        "name": name
      ]
      newChannelRef.setValue(channelItem)
    let channelStr = newChannelRef.key
    return channelStr
  
  }
 
  //MARK: Retrieve days data for the logged user
  func retrieveDaysData()  {
    
    //print("Retrieving Days data in LoginViewController for user \(appDelegate.userKey)")
    
    let ref = Database.database().reference()
    
    self.showSpinner {
      ref.child("days").child(self.appDelegate.userKey).queryOrdered(byChild: "dayIndex").observe(.value, with: { (snapshot) in

      //ref.child("days").child(self.appDelegate.userKey).queryOrdered(byChild: "dayIndex") .observeSingleEvent(of: .value, with: { (snapshot) in
      //ref.child("days").child(self.appDelegate.userKey).queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
      //ref.child("days").child(self.appDelegate.userKey).observeSingleEvent(of: .value, with: { (snapshot) in
        self.hideSpinner {
          var newItems: [Days] = []
          for item in snapshot.children {
            let day = Days(snapshot: item as! DataSnapshot)
             //newItems.insert(day, at: 0)
            newItems.append(day)
            //print("(LoginVC)Day: \(day)")
          }
          self.appDelegate.days = newItems
          //print(">>>>>>>retrieveDaysData retrieved: \(self.appDelegate.days)")
          if self.appDelegate.currentUserData.name == "empty" {
            self.callChatViewController()
          } else {
            
            self.schedulePushNotifications()
            self.callJourneyViewController()
          }
        }
      })
    }
  }
  
  
  //It is working!
  @IBAction func testLocalPushNotifications(_ sender: Any) {
    
    let content1 = UNMutableNotificationContent()
    content1.title = NSString.localizedUserNotificationString(forKey: "\(appDelegate.currentUserData.name), Aqui é o Lifer 🤖. Hora de me contar como foi o seu dia 💪🏻", arguments: nil)
    content1.body = NSString.localizedUserNotificationString(forKey: "Alguma ⭐️?", arguments: nil)
    var dateInfo1 = DateComponents()
    dateInfo1.hour = 20
    dateInfo1.minute = 0
    
    let trigger1 = UNCalendarNotificationTrigger(dateMatching: dateInfo1, repeats: true)
    // Create the request object.
    let request1 = UNNotificationRequest(identifier: "MorningAlarm", content: content1, trigger: trigger1)
    // Schedule the request.
    let center = UNUserNotificationCenter.current()
    center.add(request1) { (error : Error?) in
      if let theError = error {
        print(theError.localizedDescription)
      }
    }
  }
  
  
  func schedulePushNotifications() {
    
    let content1 = UNMutableNotificationContent()
    content1.title = NSString.localizedUserNotificationString(forKey: "\(appDelegate.currentUserData.name), Aqui é o Lifer 🤖. Hora de me contar como foi o seu dia 💪🏻", arguments: nil)
    content1.body = NSString.localizedUserNotificationString(forKey: "Alguma ⭐️?", arguments: nil)
    var dateInfo1 = DateComponents()
    dateInfo1.hour = 20
    dateInfo1.minute = 0
    
    
    let trigger1 = UNCalendarNotificationTrigger(dateMatching: dateInfo1, repeats: true)
    let request1 = UNNotificationRequest(identifier: "MorningAlarm", content: content1, trigger: trigger1)
    let center = UNUserNotificationCenter.current()
    center.add(request1) { (error : Error?) in
      if let theError = error {
        print(theError.localizedDescription)
      }
    }
 }
  
  //MARK: Retrieve user details for the logged user
  func retrieveUserData(_ user: User, completion: @escaping DataClosure)  {
    
    print("Retrieving User data in LoginViewController for user \(user.uid)")
    
    if user.uid == "" {
      print( "Empty user UID. be careful! and fix it!")
    }
    
    let ref = Database.database().reference()
    

   
/// this below works. it retrieves all users. but i need just current
//    let refCurrentUser = Database.database().reference(withPath: "users")
//    showSpinner {
//      refCurrentUser.queryOrdered(byChild: "users").observe(.value, with: { snapshot in
//          self.hideSpinner {
//          var newItems: [Users] = []
//          print(snapshot.value)
//          for item in snapshot.children {
//            let user = Users(snapshot: item as! DataSnapshot)
//            newItems.append(user)
//          }
//          self.users = newItems
//        }
//      })
//    }
  
    
    //let xxxhandle = xxxref.child("Kullanıcı").child((user.uid)).child("Yetki").observe(.value, with: { (snapshot) in
    // Esse funciona. mas nao faz o cast para Users. o de cima faz.
    
    showSpinner {
      ref.child("users").child((self.appDelegate.userKey)).observe(.value, with: { (snapshot) in
        self.hideSpinner {
           print("User Snapshot \(snapshot)")
          //if let value = snapshot.value as? Users {
          //let userData = Users(snapshot: snapshot.value as! DataSnapshot)
          //self.appDelegate.currentUserData = userData
          
          //Da pau ao converter pq nao tem os mesmos parametros
          let value = snapshot.value as? NSDictionary
          
          let age = value?["age"] as? String ?? ""
          let lastName = value?["lastName"] as? String ?? ""
          let gender = value?["gender"] as? String ?? ""
          
          let email = value?["email"] as? String ?? ""
          let finalWeight = value?["finalWeight"] as? String ?? ""
          let name = value?["name"] as? String ?? ""
        
        
        
          let startDate = value?["startDate"] as? String ?? ""
          let startWeight = value?["startWeight"] as? String ?? ""
          let totalScore = value?["totalScore"] as? String ?? ""
          let channelId = value?["channelId"] as? String ?? ""
          let lastWeight = value?["lastWeight"] as? String ?? ""
          
          
          let user = Users(email: email, name: name, lastName: lastName, gender: gender, age: age, totalScore: totalScore, startDate: startDate, startWeight: startWeight, finalWeight: finalWeight, channelId: channelId, lastWeight: lastWeight, key: self.appDelegate.userKey)
          self.appDelegate.currentUserData = user
          print(">>>>>>>retrieveUserData retrieved: \(self.appDelegate.currentUserData)")
          
          
          //Retrieve days
          self.retrieveDaysData()
          
          //end retrieve days

        }
      })
    }
  }
  
  //MARK: Call Journey
  func callJourneyViewController() {
    performUIUpdatesOnMain {
      self.performSegue(withIdentifier: self.segueJourney, sender: nil)
    }
  }
  
  //MARK: Call Chat
  func callChatViewController() {
    performUIUpdatesOnMain {
      self.performSegue(withIdentifier: self.segueChat, sender: nil)
      }
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if segue.identifier == segueChat {
      let navVc = segue.destination as! UINavigationController
      let chatVc = navVc.viewControllers.first as! ChatViewController
      
      chatVc.senderDisplayName = "Eu"
      let channel = Channel(id: appDelegate.currentUserData.channelId, name: appDelegate.currentUserData.email)
      chatVc.channel = channel
      chatVc.channelRef = channelRef.child(channel.id)
      chatVc.chatType =  ChatViewController.ChatType.welcomeChat
     print("senderDisplayName: \(chatVc.senderDisplayName)  Channel: \(channel) ChannelRef: \(channelRef.child(channel.id))")
    }
  }

  
  //MARK: Data related
  func createDay(_ day: String, _ dayIndex: Int, _ scoreAppOpened: Bool, _ scoreExercized: Bool, _ scoreAteHealthy: Bool, _ weight: String, _ weightTrendIsUp: Bool, _ isItWeekDivider: Bool, _ email: String, _ completed: Bool, _ key: String, _ weekDay: String) {
    
    let refDays = Database.database().reference(withPath: "days")
    let dayItem = Days(day: day,
                       dayIndex: dayIndex,
                       scoreAppOpened: scoreAppOpened,
                       scoreExercized: scoreExercized,
                       scoreAteHealthy: scoreAteHealthy,
                       weight: weight,
                       weightTrendisUp: weightTrendIsUp,
                       isItWeekDivider: isItWeekDivider,
                       email: email,
                       completed: completed)
    
    let dayItemRef = refDays.child(key).child(day)
    dayItemRef.setValue(dayItem.toAnyObject())
    
    
  }
  
  
  func getWeekDayFromDate(date: String) -> Int {
    
    let formatter  = DateFormatter()
    formatter.dateFormat = "yyyyMMdd"
    if let formattedDate = formatter.date(from: date) {
      let myCalendar = NSCalendar(calendarIdentifier: NSCalendar.Identifier.gregorian)!
      let myComponents = myCalendar.components(.weekday, from: formattedDate)
      let weekDay = myComponents.weekday
      
      return weekDay!


    } else {
      return 0
    }
  }
  
  func getWeekDayString(weekDay: Int) -> String {
    switch weekDay {
    case 1:
      return "domingo"
      
    case 2:
      return "segunda-feira"
      
    case 3:
      return "terça-feira"
      
    case 4:
      return "quarta-feira"
      
    case 5:
      return "quinta-feira"
      
    case 5:
      return "sexta-feira"
      
    case 7:
      return "sábado"
      
    default:
      return "invalid weekday"
    }
    
  }
  
  func createDays() {
    let numberOfDays = 21
    var day = 1
    var weekDayInt = getWeekDayFromDate(date: appDelegate.currentUserData.startDate)
    
    
    while day <= numberOfDays {
      let dia = "Dia " + String(day)
      createDay(dia, day - 1, false, false, false, "0", false, false, appDelegate.currentUserData.email, false, appDelegate.userKey, getWeekDayString(weekDay: weekDayInt))
      day = day + 1
      weekDayInt = weekDayInt + 1
      if weekDayInt > 6 {
        weekDayInt = 0
      }
    }
  }
  
  func configureLoginScreen() {
    signinButton.layer.borderWidth = 1
    signinButton.layer.cornerRadius = 5
    signinButton.layer.borderColor = UIColor.white.cgColor
    signinButton.backgroundColor = .clear
    
    signupButton.layer.borderWidth = 1
    signupButton.layer.cornerRadius = 5
    signupButton.layer.borderColor = UIColor.white.cgColor
    signupButton.backgroundColor = .clear
    
    signupStages = SignupStages.userClickedSignupFirstTime
    signinStages = SigninStages.userClickedSigninFirstTime
    
    signupIntructionLabel.isHidden = true
    signinIntructionsLabel.isHidden = true
    
    textFieldLoginEmail.isHidden = true
    textFieldLoginPassword.isHidden = true
    
    signinButton.setTitle("Já é cadastrado? Clique aqui", for: .normal)
    signupButton.setTitle("Primeira vez? Clique aqui", for: .normal)
    
  }
  
}


extension LoginViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    if textField == textFieldLoginEmail {
      textFieldLoginPassword.becomeFirstResponder()
    }
    if textField == textFieldLoginPassword {
      textField.resignFirstResponder()
    }
    return true
  }
  
}




