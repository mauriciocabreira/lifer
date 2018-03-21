//
//  OptionsViewController.swift
//  Lifer
//
//  Created by Mauricio Cabreira on 19/03/18.
//  Copyright © 2018 Mauricio Cabreira. All rights reserved.
//

import CoreLocation
import Eureka
import Firebase

typealias Emoji = String

class OptionsViewController: FormViewController {
  
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var ref: DatabaseReference!

  //MARK : Actions
  @IBAction func backToJourneyAction(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    URLRow.defaultCellUpdate = { cell, row in cell.textField.textColor = .blue }
    LabelRow.defaultCellUpdate = { cell, row in cell.detailTextLabel?.textColor = .orange  }
    CheckRow.defaultCellSetup = { cell, row in cell.tintColor = .orange }
    DateRow.defaultRowInitializer = { row in row.maximumDate = Date() }
    
    form +++
      
     Section("Dados pessoais")
     
        //Name
        <<< TextRow() {
          $0.tag = "name"
          $0.title = "Nome"
          $0.placeholder = "nome"
          $0.value = appDelegate.currentUserData.name
        }
      
      
        //Lastname
        <<< TextRow() {
          $0.tag = "lastName"
          $0.title = "Sobrenome"
          $0.placeholder = "sobrenome"
          $0.value = appDelegate.currentUserData.lastName
      }
      
        //Gender
      <<< SegmentedRow<String>() { $0.options = ["Feminino", "Masculino"]; $0.tag = "gender"; $0.value = appDelegate.currentUserData.gender }
      
      //DOB
      //<<< DateRow() { $0.value = Date(); $0.title = "Data nascimento"; $0.tag = "dob"  }
      //Age
      <<< PickerInputRow<String>("Idade"){
        $0.tag = "age"
        $0.title = "Idade"
        $0.options = []
        for i in 15...110{
          $0.options.append("\(i)")
        }
        $0.value = appDelegate.currentUserData.age
      }
      
      
// To be implemented in future versions
//      //Push notifications
//     +++ Section("Receber lembretes")
//
//        <<< SwitchRow() {
//          $0.tag = "nightPushNotificationEnabled"
//          $0.title = "Pela noite"
//          $0.value = true
//        }
//
//        <<< PickerInputRow<String>("Horário notificação noite"){
//          $0.tag = "timeNightPushNotification"
//          $0.title = "Horário"
//          $0.options = []
//          for i in 18...23{
//            $0.options.append("\(i)h")
//          }
//          $0.value = $0.options.first
//        }
//
//        <<< SwitchRow() {
//          $0.tag = "morningPushNotificationEnabled"
//          $0.title = "Pela manhã"
//          $0.value = true
//        }
//
//        <<< PickerInputRow<String>("Horário notificação manhã"){
//          $0.tag = "timeMorningPushNotification"
//          $0.title = "Horário"
//          $0.options = []
//          for i in 6...12{
//            $0.options.append("\(i)h")
//          }
//          $0.value = $0.options.first
//        }
      
      
        +++ Section()
          <<< ButtonRow() { (row: ButtonRow) -> Void in
            row.title = "Sobre"
            }
            .onCellSelection { [weak self] (cell, row) in
              self?.showVersionAlert()
        }
    
        +++ Section()
        <<< ButtonRow() { (row: ButtonRow) -> Void in
          row.title = "Sair do aplicativo"
          }
          .onCellSelection { [weak self] (cell, row) in
            self?.showAlert()
        }

  }
  
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    
    updateName()
    updateLastName()
    updateGender()
    updateAge()
    
    //To be implemented in future versions
//    let nightPushNotificationEnabledRow: TextRow? = form.rowBy(tag: "nightPushNotificationEnabled")
//    let nightPushNotificationEnabled = nightPushNotificationEnabledRow?.value
//
//    let timeNightPushNotificationRow: TextRow? = form.rowBy(tag: "timeNightPushNotification")
//    let timeNightPushNotification = timeNightPushNotificationRow?.value
//
//    let morningPushNotificationEnabledRow: TextRow? = form.rowBy(tag: "morningPushNotificationEnabled")
//    let morningPushNotificationEnabled = morningPushNotificationEnabledRow?.value
//
//    let timeMorningPushNotificationRow: TextRow? = form.rowBy(tag: "timeMorningPushNotification")
//    let timeMorningPushNotification = timeMorningPushNotificationRow?.value
    
  }
  
  func updateName() {
    ref = Database.database().reference()

    let nameRow: TextRow? = form.rowBy(tag: "name")
    if let name = nameRow?.value {
      ref.child("users/\(appDelegate.userKey)/name").setValue(name)
      appDelegate.currentUserData.name = name
    }
  }
 
  func updateLastName() {
    ref = Database.database().reference()

    let lastNameRow: TextRow? = form.rowBy(tag: "lastName")
    if let lastName = lastNameRow?.value {
      ref.child("users/\(appDelegate.userKey)/lastName").setValue(lastName)
      appDelegate.currentUserData.lastName = lastName
    }
  }
  
  func updateGender() {
    ref = Database.database().reference()

    let genderRow: SegmentedRow<String>? = form.rowBy(tag: "gender")
    if let gender = genderRow?.value {
      ref.child("users/\(appDelegate.userKey)/gender").setValue(gender)
      appDelegate.currentUserData.gender = gender
    }
  }
  
  func updateAge() {
    ref = Database.database().reference()

    let ageRow: PickerInputRow<String>? = form.rowBy(tag: "age")
    if let age = ageRow?.value {
      ref.child("users/\(appDelegate.userKey)/age").setValue(age)
      appDelegate.currentUserData.age = age
    }
  }
  
  
  @objc func multipleSelectorDone(_ item:UIBarButtonItem) {
    _ = navigationController?.popViewController(animated: true)
  }
  
  @IBAction func showVersionAlert() {
    let alertController = UIAlertController(title: "Lifer v1.0 2018", message: "tem uma idéia para o seu app ou startup? Talvez podemos ajudá-lo. Entre em contato para um bate-papo sem compromisso: mauriciocabreira@gmail.com", preferredStyle: .alert)
    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
    present(alertController, animated: true)
  }
  
  
  
  @IBAction func showAlert() {
    let alertController = UIAlertController(title: "Deseja encerrar a sessão?", message: "clique não para voltar", preferredStyle: .alert)
    //let defaultAction = UIAlertAction(title: "Não", style: .default, handler: nil)
    alertController.addAction(UIAlertAction(title: "Não", style: .default, handler: nil))
    alertController.addAction(UIAlertAction(title: "Sim", style: .default, handler: { action in
      switch action.style{
      case .default:
        print("default")
        self.userLogout()
        
      case .cancel:
        print("cancel")
        
      case .destructive:
        print("destructive")
        
        
      }}))
    present(alertController, animated: true)
  }
  
  
  
  func userLogout() {
    do {
      try Auth.auth().signOut()
      
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
    self.view.window?.rootViewController?.dismiss(animated: true, completion: nil)

    //self.dismiss(animated: false, completion: nil)
    print("cancel")
  }
  

}
