//
//  InteractiveLoginViewController.swift
//  Lifer
//
//  Created by Mauricio Cabreira on 08/02/18.
//  Copyright © 2018 Mauricio Cabreira. All rights reserved.
//



///   TO-DO : primeira imagem nao é gravada no DB e nunca aparece. fica como NOTSET. isso pq o pedido de acesso a camera aparece depois....??? a segunda em diante funciona. debugar a diferenca entre a primeira e segunda vez.


import UIKit
import Photos
import Firebase
import JSQMessagesViewController


final class ChatViewController: JSQMessagesViewController {
  
  // MARK: Properties
  
  private let imageURLNotSetKey = "NOTSET"
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  let segueJourney = "ChatToJourney"
  
  
  //MARK: Firebase variables
  
  var channelRef: DatabaseReference?
  private lazy var messageRef: DatabaseReference = self.channelRef!.child("messages")
  fileprivate lazy var storageRef: StorageReference = Storage.storage().reference(forURL: "gs://lifer-mauricio.appspot.com")
  private lazy var userIsTypingRef: DatabaseReference = self.channelRef!.child("typingIndicator").child(self.senderId)
  private lazy var usersTypingQuery: DatabaseQuery = self.channelRef!.child("typingIndicator").queryOrderedByValue().queryEqual(toValue: true)
  private var newMessageRefHandle: DatabaseHandle?
  private var updatedMessageRefHandle: DatabaseHandle?
  
  
  private var messages: [JSQMessage] = []
  private var photoMessageMap = [String: JSQPhotoMediaItem]()
  var firstName: String = ""
  
  
  private var localTyping = false
  var channel: Channel? {
    didSet {
      title = ""
      //title = channel?.name
    }
  }
  
  var isTyping: Bool {
    get {
      return localTyping
    }
    set {
      localTyping = newValue
      userIsTypingRef.setValue(newValue)
    }
  }
  
  
  var firstChatStage = FirstChatStages.botTypingWelcomeMessage
  
  enum ChatType: Int {
    case welcomeChat = 0,
    askAboutTheDay,
    weekOneEnded,
    weekTwoEnded,
    weekThreeEnded,
    programEnded
  }
  var chatType = ChatType.welcomeChat
  var currentDay: Int = 0
  
  var journeyChatStage = JourneyChatStages.botTypingWelcomeMessage
  lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
  lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
  
  //MARK: Outlets
  @IBOutlet weak var yesButton: UIButton!
  @IBOutlet weak var okButton: UIButton!
  @IBOutlet weak var noButton: UIButton!
  @IBOutlet weak var backButton: UIButton!

   // MARK: Actions
  @IBAction func backButton(_ sender: Any) {
    
    self.dismiss(animated: false, completion: nil)
  }
  
  @objc func buttonTouched(sender:UIButton!)
  {
    
    switch chatType {
    case ChatType.welcomeChat:
      buttonsEventsForWelcomeChat(sender)
      
      
    case ChatType.askAboutTheDay:
      buttonsEventsForJourneyChat(sender)
      
    default:
      break
    }
  }
  
  // MARK: View Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    assignbackground()
    //collectionView.backgroundColor = UIColor.vegaBlack
    navigationController?.isNavigationBarHidden = true
    self.inputToolbar.isHidden = true
    
    addButton("ok", okButton)
    addButton("yes", yesButton)
    addButton("no", noButton)
    addButton("back", backButton)
    reconfigureButtons()
    
    senderId = appDelegate.userKey
    observeMessages()
    messages.removeAll()
    
    if chatType == ChatType.welcomeChat {
      backButton.isHidden = true
      welcomeChat()
    } else {
      backButton.isHidden = false
      journeyChatStage = JourneyChatStages.botTypingWelcomeMessage
      collectJourneyDataChat()
    }
   
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    observeTyping()
  }
  
  
  deinit {
    if let refHandle = newMessageRefHandle {
      messageRef.removeObserver(withHandle: refHandle)
    }
    if let refHandle = updatedMessageRefHandle {
      messageRef.removeObserver(withHandle: refHandle)
    }
    
  }
  
  
  // MARK: Collection view data source (and related) methods
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
    return messages[indexPath.item]
  }
  
  override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return messages.count
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
    let message = messages[indexPath.item]
    if message.senderId == senderId {
      return outgoingBubbleImageView
    } else { 
      return incomingBubbleImageView
    }
  }
  
  override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
    
    let message = messages[indexPath.item]
    
    if message.senderId == senderId {
      cell.textView?.textColor = UIColor.white
    } else {
      cell.textView?.textColor = UIColor.black
    }
    
    return cell
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
    return nil
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
    return 15
  }
  
  override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
    let message = messages[indexPath.item]
    switch message.senderId {
    case senderId:
      return nil
    default:
      guard let senderDisplayName = message.senderDisplayName else {
        assertionFailure()
        return nil
      }
      return NSAttributedString(string: senderDisplayName)
    }
  }
  
  
  
  // MARK: Firebase related methods
  private func observeMessages() {
    
    messageRef = channelRef!.child("messages")
    let messageQuery = messageRef.queryLimited(toLast:25)
    
    // We can use the observe method to listen for new
    // messages being written to the Firebase DB
    newMessageRefHandle = messageQuery.observe(.childAdded, with: { (snapshot) -> Void in
      
      //Only "listen" messages when first chat is finished
      if self.firstChatStage == FirstChatStages.chatDone {
        
        let messageData = snapshot.value as! Dictionary<String, String>
        
        if let id = messageData["senderId"] as String!, let name = messageData["senderName"] as String!, let text = messageData["text"] as String!, text.characters.count > 0 {
          
          self.addMessage(withId: id, name: name, text: text)
          self.finishReceivingMessage()
        } else if let id = messageData["senderId"] as String!, let photoURL = messageData["photoURL"] as String! {
          if let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: id == self.senderId) {
            self.addPhotoMessage(withId: id, key: snapshot.key, mediaItem: mediaItem)
            
            if photoURL.hasPrefix("gs://") {
              self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: nil)
            }
          }
        } else {
          print("Error! Could not decode message data")
        }
        
      }
    })
    
    // We can also use the observer method to listen for
    // changes to existing messages.
    // We use this to be notified when a photo has been stored
    // to the Firebase Storage, so we can update the message data
    updatedMessageRefHandle = messageRef.observe(.childChanged, with: { (snapshot) in
      let key = snapshot.key
      let messageData = snapshot.value as! Dictionary<String, String>
      
      if let photoURL = messageData["photoURL"] as String! {
        // The photo has been updated.
        if let mediaItem = self.photoMessageMap[key] {
          self.fetchImageDataAtURL(photoURL, forMediaItem: mediaItem, clearsPhotoMessageMapOnSuccessForKey: key)
        }
      }
    })
  }
  
  
  
  private func fetchImageDataAtURL(_ photoURL: String, forMediaItem mediaItem: JSQPhotoMediaItem, clearsPhotoMessageMapOnSuccessForKey key: String?) {
    let storageRef = Storage.storage().reference(forURL: photoURL)
    
    storageRef.getData(maxSize: INT64_MAX){ (data, error) in
      
      if let error = error {
        print("Error downloading image data: \(error)")
        return
      }
      
      storageRef.getMetadata(completion: { (metadata, metadataErr) in
        if let error = metadataErr {
          print("Error downloading metadata: \(error)")
          return
        }
        
        if (metadata?.contentType == "image/gif") {
          mediaItem.image = UIImage.gif(data: data!)
        } else {
          mediaItem.image = UIImage.init(data: data!)
        }
        self.collectionView.reloadData()
        
        guard key != nil else {
          return
        }
        self.photoMessageMap.removeValue(forKey: key!)
      })
    }
  }
  
  private func observeTyping() {
    
    //This is commented because I am not using at the moment interaction with other users. Just the bot, which is local and I do not store his messages to Firebase. Neither user's messages.
    
    //    let typingIndicatorRef = channelRef!.child("typingIndicator")
    //    userIsTypingRef = typingIndicatorRef.child(senderId)
    //    userIsTypingRef.onDisconnectRemoveValue()
    //    usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
    //
    //    usersTypingQuery.observe(.value) { (data: DataSnapshot) in
    //
    //      //  // You're the only typing, don't show the indicator
    //        if data.childrenCount == 1 && self.isTyping {
    //          return
    //        }
    //        // Are there others typing?
    //        self.showTypingIndicator = data.childrenCount > 0
    //        self.scrollToBottom(animated: true)
    //    }
  }
  

  
  override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
    
    self.inputToolbar.contentView.textView.resignFirstResponder()
    
    print("withMessageText: \(text)  senderId: \(senderId) senderDisplayName: \(senderDisplayName) date: \(date)  ")
    let itemRef = messageRef.childByAutoId()
    
    let messageItem = [
      "senderId": senderId!,
      "senderName": senderDisplayName!,
      "text": text!,
      ]
    itemRef.setValue(messageItem)
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    finishSendingMessage()
    isTyping = false
    
     if chatType == ChatType.askAboutTheDay {
      if journeyChatStage == JourneyChatStages.botAskingWeight {
        
        addMessage(withId: appDelegate.userKey, name: "Eu", text: text, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        var updateWeightLastDay = false
        if currentDay == 20 {
          updateWeightLastDay = true
        }
        
        if self.updateUserWeight(text, false, updateWeightLastDay) {
          self.journeyChatStage = JourneyChatStages.userTypedWeight
          collectJourneyDataChat()
          self.scrollToBottom(animated: true)
          
          
        } else {
          //Message and ask age again
          self.showTypingIndicator = true
          self.scrollToBottom(animated: true)
          
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
            self.showTypingIndicator = false
            self.addMessage(withId: "Lifer", name: "Lifer", text: "Peso inválido. Digite novamente:", hideKeyboard: false, hideYesButton: true, hideOkButton: true, hideNoButton: true)
          })
        }
        
      }
      
      
    } else {
      if chatType == ChatType.welcomeChat {
        
        
        if firstChatStage != FirstChatStages.chatDone {
          
          //Chat to collect data and tutorial is on
          switch self.firstChatStage {
          case FirstChatStages.botAskingName:
            self.updateUserName(name: text)
            self.firstChatStage = FirstChatStages.botAskingAge
            addMessage(withId: appDelegate.userKey, name: "Eu", text: text, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
            welcomeChat()
            
          case FirstChatStages.botAskingAge:
            addMessage(withId: appDelegate.userKey, name: "Eu", text: text, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
            
            if self.updateUserAge(age: text) {
              self.firstChatStage = FirstChatStages.botAskingGender
              welcomeChat()
            } else {
              //Message and ask age again
              self.showTypingIndicator = true
              self.scrollToBottom(animated: true)
              
              DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                self.showTypingIndicator = false
                self.addMessage(withId: "Lifer", name: "Lifer", text: "Idade inválida. Digite novamente:", hideKeyboard: false, hideYesButton: true, hideOkButton: true, hideNoButton: true)
              })
            }
            
          case FirstChatStages.botAskingWeight:
            addMessage(withId: appDelegate.userKey, name: "Eu", text: text, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
            
            if self.updateUserWeight(text, true, false) {
              self.firstChatStage = FirstChatStages.botAskingIfUserCan
              welcomeChat()
              
            } else {
              //Message and ask age again
              self.showTypingIndicator = true
              self.scrollToBottom(animated: true)
              
              DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(0), execute: {
                self.showTypingIndicator = false
                self.addMessage(withId: "Lifer", name: "Lifer", text: "Peso inválido. Digite novamente:", hideKeyboard: false, hideYesButton: true, hideOkButton: true, hideNoButton: true)
              })
            }
            
          default:
            break
          }
        }
      }
      
    }
  }
  
  func sendPhotoMessage() -> String? {
    let itemRef = messageRef.childByAutoId()
    
    let messageItem = [
      "photoURL": imageURLNotSetKey,
      "senderId": senderId!,
      ]
    
    itemRef.setValue(messageItem)
    
    JSQSystemSoundPlayer.jsq_playMessageSentSound()
    
    finishSendingMessage()
    return itemRef.key
  }
  
  func setImageURL(_ url: String, forPhotoMessageWithKey key: String) {
    let itemRef = messageRef.child(key)
    itemRef.updateChildValues(["photoURL": url])
  }
  
  // MARK: UI and User Interaction
  
  private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
  }
  
  private func setupIncomingBubble() -> JSQMessagesBubbleImage {
    let bubbleImageFactory = JSQMessagesBubbleImageFactory()
    return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
  }
  
  override func didPressAccessoryButton(_ sender: UIButton) {
    let picker = UIImagePickerController()
    picker.delegate = self
    if (UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera)) {
      picker.sourceType = UIImagePickerControllerSourceType.camera
    } else {
      picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
    }
    
    present(picker, animated: true, completion:nil)
  }
  
  func addMessage(withId id: String, name: String, text: String) {
    if let message = JSQMessage(senderId: id, displayName: name, text: text) {
      messages.append(message)
    }
  }
  
  func addMessage(withId id: String, name: String, text: String, hideKeyboard: Bool, hideYesButton: Bool, hideOkButton: Bool, hideNoButton: Bool) {
    if let message = JSQMessage(senderId: id, displayName: name, text: text) {
      messages.append(message)
      finishSendingMessage()
      scrollToBottom(animated: true)
    }

    //reconfigureButtons()

    inputToolbar.isHidden = hideKeyboard
    yesButton.isHidden = hideYesButton
    okButton.isHidden = hideOkButton
    noButton.isHidden = hideNoButton
    keyboardController.textView.isHidden = hideKeyboard
  }
  
  
  private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
    if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
      messages.append(message)
      
      if (mediaItem.image == nil) {
        photoMessageMap[key] = mediaItem
      }
      
      collectionView.reloadData()
    }
  }
  
  
  // MARK: UITextViewDelegate methods
  
  override func textViewDidChange(_ textView: UITextView) {
    super.textViewDidChange(textView)
    // If the text is not empty, the user is typing
    isTyping = textView.text != ""
  }
  
  func updateUserName(name: String) {
    var ref: DatabaseReference!
    
    ref = Database.database().reference()
    ref.child("users/\(appDelegate.userKey)/name").setValue(name)
    appDelegate.currentUserData.name = name
    firstName = name
    print("User name set to set to \(name)")
    
  }

  func updateGenderToFemale(_ isFemale: Bool) {
    var ref: DatabaseReference!
    
    ref = Database.database().reference()
    let gender = isFemale ? "Feminino" : "Masculino"

    ref.child("users/\(appDelegate.userKey)/gender").setValue(gender)
    appDelegate.currentUserData.gender = gender
  }

  
  func updateUserAge(age: String) -> Bool {
    var ref: DatabaseReference!
    
    if let ageInt = Int(age) {
      if ageInt >= 15 && ageInt <= 105 {
        
        ref = Database.database().reference()
        ref.child("users/\(appDelegate.userKey)/age").setValue(age)
        appDelegate.currentUserData.age = age
        
        print("User age set to set to \(age)")
        return true
      } else {
        print("Age not in range")
        
      }
    } else {
      print("Age is not a number \(age)")
      
    }
    return false
    
  }
  
  func updateUserWeight(_ weight: String, _ startWeight: Bool, _ finalWeight: Bool) -> Bool {
    var ref: DatabaseReference!
    
    if let weightInt = Int(weight) {
      if weightInt >= 40 && weightInt <= 150 {
        
        ref = Database.database().reference()
        ref.child("days/\(appDelegate.userKey)/\(appDelegate.days[currentDay].day)/weight").setValue(weight)
        appDelegate.days[currentDay].weight = weight
        
        if startWeight {
          ref.child("users/\(appDelegate.userKey)/startWeight").setValue(weight)
          appDelegate.currentUserData.startWeight = weight
          
        } else {
          if finalWeight {
            ref.child("users/\(appDelegate.userKey)/finalWeight").setValue(weight)
            appDelegate.currentUserData.finalWeight = weight
          }
          
          //Update  weight trend
          if let doubleLastWeight = Double(appDelegate.currentUserData.lastWeight), let doubleNewWeight = Double(weight) {
            if doubleNewWeight.isLess(than: doubleLastWeight) {
              //Losing weight  (down) / false
              ref.child("days/\(appDelegate.userKey)/\(appDelegate.days[currentDay].day)/weightTrendisUp").setValue(false)
              appDelegate.days[currentDay].weightTrendisUp = false
              
              
            } else {
              ref.child("days/\(appDelegate.userKey)/\(appDelegate.days[currentDay].day)/weightTrendisUp").setValue(true)
              appDelegate.days[currentDay].weightTrendisUp = true
            }
          } else {
            print("some error occurred")
          }
          
          ref.child("users/\(appDelegate.userKey)/lastWeight").setValue(weight)
          appDelegate.currentUserData.lastWeight = weight
          
        }
        return true
        
        
      } else {
        print("Weight not in range")
          
      }
        
    } else {
      print("Weight is not a number \(weight)")
    }
    
    
    return false
    
  }
  
  func updateUserStarExercized(_ didIt: Bool) {
    var ref: DatabaseReference!
    ref = Database.database().reference()
    ref.child("days/\(appDelegate.userKey)/\(appDelegate.days[currentDay].day)/scoreExercized").setValue(didIt)
    appDelegate.days[currentDay].scoreExercized = didIt
  }
  
  func updateUserStarAteHealthy(_ didIt: Bool) {
    var ref: DatabaseReference!
    ref = Database.database().reference()
    ref.child("days/\(appDelegate.userKey)/\(appDelegate.days[currentDay].day)/scoreAteHealthy").setValue(didIt)
    appDelegate.days[currentDay].scoreAteHealthy = didIt
  }
  
  func updateUserStarAppOpened(_ didIt: Bool) {
    var ref: DatabaseReference!
    ref = Database.database().reference()
    ref.child("days/\(appDelegate.userKey)/\(appDelegate.days[currentDay].day)/scoreAppOpened").setValue(didIt)
    appDelegate.days[currentDay].scoreAppOpened = didIt
  }
  
  func setDayTo(_ day: Days, _ status: Bool) {
    
    var ref: DatabaseReference!
    
    ref = Database.database().reference()
    ref.child("days/\(appDelegate.userKey)/\(day.day)/completed").setValue(status)
    appDelegate.days[currentDay].completed = status
    print("\(appDelegate.days[currentDay].day) set to \(status)")
    
  }
  
  
  // MARK: Add/configure buttons programatically
  @objc fileprivate func addButton(_ type: String, _ button: UIButton) {
    
    button.addTarget(self, action: #selector(buttonTouched), for: .touchUpInside)
    self.view.addSubview(button)
    
  }
  
  func reconfigureButtons() {
      okButton.layer.cornerRadius = 15
    
      NSLayoutConstraint(item: okButton, attribute: NSLayoutAttribute.centerX , relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 0).isActive = true
      NSLayoutConstraint(item: okButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -7).isActive = true
      okButton.isHidden = true
      
      
      yesButton.layer.cornerRadius = 15
      NSLayoutConstraint(item: yesButton, attribute: NSLayoutAttribute.centerX , relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: -130).isActive = true
      NSLayoutConstraint(item: yesButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -7).isActive = true
      yesButton.isHidden = true
      
      
      noButton.layer.cornerRadius = 15
      NSLayoutConstraint(item: noButton, attribute: NSLayoutAttribute.centerX , relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.centerX, multiplier: 1, constant: 130).isActive = true
      NSLayoutConstraint(item: noButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.bottom, multiplier: 1, constant: -7).isActive = true
      noButton.isHidden = true
      
      NSLayoutConstraint(item: backButton, attribute: NSLayoutAttribute.right , relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.right, multiplier: 1, constant: -10).isActive = true
      NSLayoutConstraint(item: backButton, attribute: NSLayoutAttribute.bottom, relatedBy: NSLayoutRelation.equal, toItem: view, attribute: NSLayoutAttribute.top, multiplier: 1, constant: 60).isActive = true
      backButton.isHidden = false
      
    
  
  }
  
  
  // MARK: configure background programatically because I am using a pod for the chat and dont want to touch it.
  func assignbackground() {
    
    let background = UIImage(named: "bg6.png")
    
    var imageView : UIImageView!
    imageView = UIImageView(frame: view.bounds)
    imageView.contentMode =  UIViewContentMode.scaleAspectFill
    imageView.clipsToBounds = true
    imageView.image = background
    imageView.center = view.center
    collectionView.backgroundView = imageView
  }
  
  
  
  
  //MARK: Call Journey
  func callJourneyViewController() {
    performUIUpdatesOnMain {
      self.performSegue(withIdentifier: self.segueJourney, sender: nil)
    }
  }
  
}

// MARK: Image Picker Delegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  
  func imagePickerController(_ picker: UIImagePickerController,
                             didFinishPickingMediaWithInfo info: [String : Any]) {
    
    picker.dismiss(animated: true, completion:nil)
    
    if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
      
      let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
      let asset = assets.firstObject
      if let key = sendPhotoMessage() {
        asset?.requestContentEditingInput(with: nil, completionHandler: { (contentEditingInput, info) in
          let imageFileURL = contentEditingInput?.fullSizeImageURL
          
          let path = "\(Auth.auth().currentUser?.uid)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
          
          print("path: \(path)")
          self.storageRef.child(path).putFile(from: imageFileURL!, metadata: nil) { (metadata, error) in
            if let error = error {
              print("Error uploading photo: \(error.localizedDescription)")
              return
            }
            self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
          }
        })
      }
    } else {
      let image = info[UIImagePickerControllerOriginalImage] as! UIImage
      
      if let key = sendPhotoMessage() {
        let imageData = UIImageJPEGRepresentation(image, 1.0)
        let imagePath = Auth.auth().currentUser!.uid + "/\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpg"
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        storageRef.child(imagePath).putData(imageData!, metadata: metadata) { (metadata, error) in
          if let error = error {
            print("Error uploading photo: \(error)")
            return
          }
          self.setImageURL(self.storageRef.child((metadata?.path)!).description, forPhotoMessageWithKey: key)
        }
      }
      
    }
  }
  
  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
    picker.dismiss(animated: true, completion:nil)
  }
  
  
}
