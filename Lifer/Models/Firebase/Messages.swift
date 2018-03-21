//
//  MemeMeStruct.swift
//  Meme
//
//  Created by Mauricio A Cabreira on 24/05/17.
//  Copyright © 2017 Mauricio A Cabreira. All rights reserved.
//

import Foundation
import UIKit

struct Message {
  let messageContent: String!
  let sender: Agent!
  }

enum Agent: Int {
  case bot = 0, user
}

