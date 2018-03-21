//
//  WelcomeChat.swift
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

  enum FirstChatStages: Int {
    case botTypingWelcomeMessage = 0,
    botSendWelcomeMessage,
    botAskingName,
    userTypeName,
    botAskingAge,
    userTypeAge,
    botAskingGender,
    userInformedGender,
    botAskingWeight,
    botAskingIfUserCan,
    userSaidSheCan,
    userSaidLetsGo,
    chatDone
  }

  func welcomeChat() {
    
    switch firstChatStage {
    case FirstChatStages.botTypingWelcomeMessage:
      
      self.showTypingIndicator = true
      self.scrollToBottom(animated: true)
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        self.showTypingIndicator = false
        self.addMessage(withId: "Lifer", name: "Lifer", text: "Olá! Me chamo Lifer - porque tenho hábitos saudáveis desde o dia que fui criado, e serei o seu coach pessoal nos próximos 21 dias. ", hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        self.showTypingIndicator = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
          self.showTypingIndicator = false
          self.firstChatStage = FirstChatStages.botAskingName
          self.addMessage(withId: "Lifer", name: "Lifer", text: "E você, qual o seu primeiro nome?", hideKeyboard: false, hideYesButton: true, hideOkButton: true, hideNoButton: true)
          
        })
        
      })
      
    case FirstChatStages.botAskingAge:
      self.showTypingIndicator = true
      self.scrollToBottom(animated: true)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        self.showTypingIndicator = false
        let sentence = "Olá " + self.firstName + ", muito prazer. Por favor informe a sua idade:"
        self.addMessage(withId: "Lifer", name: "Lifer", text: sentence, hideKeyboard: false, hideYesButton: true, hideOkButton: true, hideNoButton: true)
      })
      
    case FirstChatStages.botAskingGender:
      self.showTypingIndicator = true
      self.scrollToBottom(animated: true)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        self.showTypingIndicator = false
        let sentence = "Olá " + self.firstName + ", muito prazer. Por gentileza pode informar o seu gênero?"
        self.addMessage(withId: "Lifer", name: "Lifer", text: sentence, hideKeyboard: true, hideYesButton: false, hideOkButton: true, hideNoButton: false)
        self.yesButton.setTitle(" Feminino ", for: .normal)
        self.noButton.setTitle(" Masculino ", for: .normal)
        
      })
      
    case FirstChatStages.botAskingWeight:
      self.showTypingIndicator = true
      self.scrollToBottom(animated: true)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        self.showTypingIndicator = false
        self.addMessage(withId: "Lifer", name: "Lifer", text: "E para terminar, por favor digite o seu peso:", hideKeyboard: false, hideYesButton: true, hideOkButton: true, hideNoButton: true)
      })
      break
      
    case FirstChatStages.botAskingIfUserCan:
      
      self.inputToolbar.isHidden = false
      self.showTypingIndicator = true
      self.scrollToBottom(animated: true)
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
        self.inputToolbar.isHidden = false
        self.showTypingIndicator = false
        self.addMessage(withId: "Lifer", name: "Lifer", text: "Tudo pronto. Começamos agora a jornada 💪🏼 Talvez você se saia bem 🤔", hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        
        self.showTypingIndicator = true
        
        
        
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
          self.showTypingIndicator = false
          self.addMessage(withId: "Lifer", name: "Lifer", text: "OBJETIVO 🥇: Se exercitar 🏊🏼‍♀️🏋🏻‍♀️🤸🏼‍♀️🚴🏻‍♀️🏃🏻‍♀️ e evitar excessos na alimentação 🍩🍕🍔 nos próximos 2️⃣1️⃣ dias.", hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
          self.showTypingIndicator = true
          
          DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            self.showTypingIndicator = false
            self.addMessage(withId: "Lifer", name: "Lifer", text: "INSTRUÇÕES: Diariamente você abre o app e clica no dia atual.", hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
            
            self.showTypingIndicator = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
              self.showTypingIndicator = false
              self.addMessage(withId: "Lifer", name: "Lifer", text: "Ganhe até 3 ⭐️ por dia.", hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
              self.showTypingIndicator = true
              
              DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                self.showTypingIndicator = false
                self.addMessage(withId: "Lifer", name: "Lifer", text: "1 ⭐️ ao abrir o app. Easy! 👌🏻", hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
                
                self.showTypingIndicator = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                  self.showTypingIndicator = false
                  self.addMessage(withId: "Lifer", name: "Lifer", text: "1 ⭐️ quando 🏊🏼‍♀️🏋🏻‍♀️🤸🏼‍♀️🚴🏻‍♀️🏃🏻‍♀️! 30 minutos de caminhada no dia é o suficiente 😉", hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
                  
                  self.showTypingIndicator = true
                  DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
                    self.showTypingIndicator = false
                    self.addMessage(withId: "Lifer", name: "Lifer", text: "1 ⭐️ quando evitar excessos, doces, ... 🍩🍕🍔. ", hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
                    
                    self.showTypingIndicator = true
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
                      self.showTypingIndicator = false
                      self.addMessage(withId: "Lifer", name: "Lifer", text: "Será que você vai conseguir 3⭐️ algum dia? E chegar até o dia 21 mais fit?", hideKeyboard: true, hideYesButton: true, hideOkButton: false, hideNoButton: true)
                      if self.appDelegate.currentUserData.gender == "Feminino" {
                        self.okButton.setTitle("     Claro que sim! 🙋🏻‍♀️👊🏼     ", for: .normal)
                      } else {
                        self.okButton.setTitle("     Claro que sim! 🙋🏻‍♂️👊🏼     ", for: .normal)
                      }
                      
                    })
                  })
                })
              })
            })
          })
        })
      })
      
    case FirstChatStages.userSaidSheCan:
      self.showTypingIndicator = true
      //self.scrollToBottom(animated: true)
      
      DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
        self.addMessage(withId: "Lifer", name: "Lifer", text: "👊🏽 É esse o espirito, mas só os dias irão dizer.", hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
        self.backButton.isHidden = false
        
        self.showTypingIndicator = true
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(3), execute: {
          self.showTypingIndicator = false
          self.addMessage(withId: "Lifer", name: "Lifer", text: "Já começamos. Clique no ❌ no topo da tela. E na janela seguinte clique no Dia 1 para ganhar a sua primeira ⭐️", hideKeyboard: true, hideYesButton: true, hideOkButton: false, hideNoButton: true)
          self.okButton.setTitle("     Vamos lá! 😼     ", for: .normal)
          self.firstChatStage = FirstChatStages.userSaidLetsGo
          
        })
      })
      
      
    default:
      break
      
    }
  }
  
  //Manage the events/user info related to the Welcome chat
  
  func buttonsEventsForWelcomeChat(_ sender: UIButton) {
    switch sender {
    case okButton:
      print("OK Button pressed")
      if chatType == ChatType.welcomeChat {
        if firstChatStage == FirstChatStages.botAskingIfUserCan {
          firstChatStage = FirstChatStages.userSaidSheCan
          addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
          welcomeChat()
        }
        
      }
      
      
      if firstChatStage == FirstChatStages.userSaidLetsGo {
        firstChatStage = FirstChatStages.chatDone
        addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
    
      }

    case yesButton:
      print("Sim Button pressed")
      if chatType == ChatType.welcomeChat {
        if firstChatStage == FirstChatStages.botAskingGender {
          firstChatStage = FirstChatStages.botAskingWeight
          addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
          updateGenderToFemale(true)
          welcomeChat()
        }
        
      }
      
 
    case noButton:
      print("Não Button pressed")
      if chatType == ChatType.welcomeChat {
        if firstChatStage == FirstChatStages.botAskingGender {
          firstChatStage = FirstChatStages.botAskingWeight
          addMessage(withId: appDelegate.userKey, name: "Eu", text: sender.currentTitle!, hideKeyboard: true, hideYesButton: true, hideOkButton: true, hideNoButton: true)
          updateGenderToFemale(false)
          welcomeChat()
        }
        
      }

    case backButton:
      print("Back Button pressed")
      callJourneyViewController()
      
    default:
      break
      
    }
  }
  
  
  
  
}
