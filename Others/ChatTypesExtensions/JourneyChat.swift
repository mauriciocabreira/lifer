//
//  JourneyChat.swift
//  Lifer
//
//  Created by Mauricio Cabreira on 18/03/18.
//  Copyright © 2018 Mauricio Cabreira. All rights reserved.
//

import UIKit
import Photos
import Firebase
import JSQMessagesViewController

extension ChatViewController {
  
  enum JourneyChatStages: Int {
    case botTypingWelcomeMessage = 0,
    botSendWelcomeMessage,
    botAskingExercized,
    userSaidExercized,
    userSaidDidNotExercise,
    botAskingAteHealthy,
    userSaidAteHealthy,
    userSaidDidNotAteHealthy,
    userSaidDoNotWantToInformWeight,
    botAskingWeight,
    userTypedWeight,
    userSaidInformLater,
    userPromising,
    userPromised,
    botSayingGoodBye,
    chatDone
  }
  
  //MARK : Collect info about the day
  
  func collectJourneyDataChat() {
    
    switch journeyChatStage {
      
    case JourneyChatStages.botTypingWelcomeMessage:
      
      self.showTypingIndicator = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        self.showTypingIndicator = false
        self.updateUserStarAppOpened(true)
        
        var message: String
        switch self.currentDay {
        case 0:
          message = "Você fez check-in no primeiro dia. 1 ⭐️ garantida."
          
        case 1:
          message = "Bem-vindo ao dia \(self.currentDay + 1). ⭐️ pra você por fazer o check-in diário."
          
        case 2:
          message = "Bem-vindo ao dia \(self.currentDay + 1). 1 ⭐️ por seguir no jogo."
          
        default:
          message = "Dia \(self.currentDay + 1). Ganhou 1⭐️. Estou adorando!"
          
        }
        
        self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        
        self.showTypingIndicator = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
          self.showTypingIndicator = false
          
          var message: String
          if (self.currentDay == 0) {
            message = "Vamos lá, me conte como foi."
          } else {
            message = "Vamos lá. Curioso para saber como foi 🙏🏻"
          }
          self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
          self.showTypingIndicator = true
          
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
            
            self.showTypingIndicator = false
            self.journeyChatStage = JourneyChatStages.botAskingExercized
            self.addMessage(withId: "Tbot", name: "Tbot", text: "Você se exercitou?", hideKeyboard: true, hideYesButton: false, hideOkButton: false, hideNoButton: false)
            
            self.yesButton.setTitle(" Sim ⭐️ ", for: .normal)
            self.okButton.setTitle(" Ainda não. Volto depois ", for: .normal)
            self.noButton.setTitle(" Não 👎🏼 ", for: .normal)
            
            
          })
        })
        
      })
      
    case JourneyChatStages.userSaidExercized:
      self.showTypingIndicator = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        
        self.showTypingIndicator = false
        self.journeyChatStage = JourneyChatStages.botAskingAteHealthy
        
        var message: String
        if (self.currentDay == 0) {
          message = "Yes! Começamos bem! Agora a alimentação: você evitou excessos 🍕🍩🍔🍟?"
        } else {
          message = "Demais!. E a alimentação: você evitou excessos 🍕🍩🍔🍟?"
        }
        self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: false, hideOkButton: true, hideNoButton: false)
        
        self.yesButton.setTitle(" Sim ⭐️ ", for: .normal)
        self.noButton.setTitle(" Não 👎🏼", for: .normal)
        
        
      })
      
    case JourneyChatStages.userSaidDidNotExercise:
      self.showTypingIndicator = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        
        self.showTypingIndicator = false
        self.journeyChatStage = JourneyChatStages.botAskingAteHealthy
        
        var message: String
        if (self.currentDay == 0) {
          message = "Estamos começando. Não se preocupe que vamos recuperar! Agora a alimentação: você evitou excessos 🍕🍩🍔🍟?"
        } else {
          message = "Que pena. E a alimentação: você evitou excessos 🍕🍩🍔🍟?"
        }
        self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: false, hideOkButton: true, hideNoButton: false)
        
        self.yesButton.setTitle(" Sim ⭐️ ", for: .normal)
        self.noButton.setTitle(" Não 👎🏼", for: .normal)
        
        
      })
      
      
    case JourneyChatStages.userSaidAteHealthy:
      
      self.showTypingIndicator = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        
        self.showTypingIndicator = false
        self.journeyChatStage = JourneyChatStages.userPromising
        
        var message: String
        message = "Excelente. Será que você consegue amanhã tambem?"
        self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: true, hideOkButton: false, hideNoButton: true)
        self.okButton.setTitle(" Claro 🖖🏼 ", for: .normal)
        self.setDayTo(self.appDelegate.days[self.currentDay], true)
        
      })
      
    case JourneyChatStages.userSaidDidNotAteHealthy:
      self.showTypingIndicator = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        
        self.showTypingIndicator = false
        self.journeyChatStage = JourneyChatStages.userPromising
        
        var message: String
        message = "Acontece. Mas os excessos na alimentação devem ser excessões! O exercício dá força para segurar as tentações! :-)"
        self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: true, hideOkButton: false, hideNoButton: true)
        self.okButton.setTitle(" Verdade 🖖🏼 ", for: .normal)
        self.setDayTo(self.appDelegate.days[self.currentDay], true)
        
      })
      
    case JourneyChatStages.userSaidInformLater:
      self.showTypingIndicator = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        
        self.showTypingIndicator = false
        self.journeyChatStage = JourneyChatStages.botSayingGoodBye
        
        let message = "Legal, nos vemos mais tarde!"
        self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: true, hideOkButton: false, hideNoButton: true)
        
        self.okButton.setTitle(" Combinado 👍🏻 ", for: .normal)
        
        
      })
      
    case JourneyChatStages.userPromised:
      
      self.showTypingIndicator = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        
        self.showTypingIndicator = false
        let message = "Isso aí"
        self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        
        self.showTypingIndicator = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
          
          self.showTypingIndicator = false
          var message: String
          //Log weight day
          if self.currentDay == 4 || self.currentDay == 9 || self.currentDay == 14 || self.currentDay == 20  {
            //dia de informar o peso
            self.journeyChatStage = JourneyChatStages.botAskingWeight
            message = "Qual o seu peso hoje?"
            self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: false, hideYesButton: true, hideOkButton: true, hideNoButton: true)
          } else {
            
            if self.currentDay == 3 || self.currentDay == 8 || self.currentDay == 13 || self.currentDay == 19  {
              message = "E amanhã é dia de informar o seu peso 😎. Até lá."
            } else {
              message = "Vamos continuar assim! Nos vemos amanhã."
            }
            self.journeyChatStage = JourneyChatStages.botSayingGoodBye
            self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: true, hideOkButton: false, hideNoButton: true)
            self.okButton.setTitle(" Até mais. 👍🏻 ", for: .normal)
          }
          
        })
      })

      
    case JourneyChatStages.userTypedWeight:
      self.showTypingIndicator = true
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        
        self.showTypingIndicator = false
        self.journeyChatStage = JourneyChatStages.botSayingGoodBye
        
        let message = "Peso armazenado. Vamos comparar no fim do periodo a sua evolução. Por hoje é só. Nos vemos amanhã"
        self.addMessage(withId: "Tbot", name: "Tbot", text: message, hideKeyboard: true, hideYesButton: true, hideOkButton: false, hideNoButton: true)
        
        self.okButton.setTitle(" Até mais. 👍🏻 ", for: .normal)
        
        
      })
      
      
      
    default:
      break
      
    }
  }
  
  //Manage the events/user info related to the Journey Day chat
  
  func buttonsEventsForJourneyChat(_ sender: UIButton) {
    switch sender {
    case okButton:
      print("OK Button pressed")
      
      switch journeyChatStage {
      case JourneyChatStages.botAskingExercized:
        print("User said it will come back later")
        
        journeyChatStage = JourneyChatStages.userSaidInformLater
        addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        collectJourneyDataChat()
        
        
      case JourneyChatStages.userPromising:
        print("Promising")
        
        journeyChatStage = JourneyChatStages.userPromised
        addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        collectJourneyDataChat()
        
      case JourneyChatStages.botSayingGoodBye:
        print("Bye")
        
        journeyChatStage = JourneyChatStages.chatDone
        addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        
      default:
        break
        
      }
      
      
      
    case yesButton:
      print("Sim Button pressed")
      
      switch journeyChatStage {
      case JourneyChatStages.botAskingExercized:
        print("User said exercized")
        
        journeyChatStage = JourneyChatStages.userSaidExercized
        addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        updateUserStarExercized(true)
        collectJourneyDataChat()
        
      case JourneyChatStages.botAskingAteHealthy:
        print("User said ate ok")
        
        journeyChatStage = JourneyChatStages.userSaidAteHealthy
        addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        updateUserStarAteHealthy(true)
        collectJourneyDataChat()
        
      default:
        break
        
      }
      
      
      
    case noButton:
      print("Não Button pressed")
      switch journeyChatStage {
      case JourneyChatStages.botAskingExercized:
        print("User said did not exercise")
        
        journeyChatStage = JourneyChatStages.userSaidDidNotExercise
        addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        updateUserStarExercized(false)
        
        collectJourneyDataChat()
        
      case JourneyChatStages.botAskingAteHealthy:
        print("User said did not eat healthy")
        
        journeyChatStage = JourneyChatStages.userSaidDidNotAteHealthy
        addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        updateUserStarAteHealthy(false)
        
        collectJourneyDataChat()
        
      default:
        break
        
      }
      
      
    case backButton:
      print("Back Button pressed")
      callJourneyViewController()
      
    default:
      break
      
    }
  }
}
