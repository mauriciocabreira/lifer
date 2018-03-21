

import Foundation
import Firebase


struct Days {
  
  var key: String
  var day: String
  var dayIndex: Int
  var scoreAppOpened: Bool
  var scoreExercized: Bool
  var scoreAteHealthy: Bool
  var weight: String
  var weightTrendisUp: Bool // false = trend down = good: losing weight
  var email: String
  var isItWeekDivider: Bool // add a week divider, and not a standard cell to the listVC
  var ref: DatabaseReference?
  var completed: Bool
  
  init(day: String, dayIndex: Int, scoreAppOpened: Bool, scoreExercized: Bool, scoreAteHealthy: Bool, weight: String, weightTrendisUp: Bool, isItWeekDivider: Bool, email: String, completed: Bool, key: String = "") {
    self.key = key
    self.day = day
    self.dayIndex = dayIndex
    self.scoreAppOpened = scoreAppOpened
    self.scoreExercized = scoreExercized
    self.scoreAteHealthy = scoreAteHealthy
    self.weight = weight
    self.weightTrendisUp = weightTrendisUp
    self.isItWeekDivider = isItWeekDivider
    self.email = email
    self.completed = completed
    self.ref = nil
  }
  
  init(snapshot: DataSnapshot) {
    key = snapshot.key
    let snapshotValue = snapshot.value as! [String: AnyObject]
    
    
    day = snapshotValue["day"] as! String
    dayIndex = snapshotValue["dayIndex"] as! Int
    scoreAppOpened = snapshotValue["scoreAppOpened"] as! Bool
    scoreExercized = snapshotValue["scoreExercized"] as! Bool
    scoreAteHealthy = snapshotValue["scoreAteHealthy"] as! Bool
    weight = snapshotValue["weight"] as! String
    weightTrendisUp = snapshotValue["weightTrendisUp"] as! Bool
    isItWeekDivider = snapshotValue["isItWeekDivider"] as! Bool
    email = snapshotValue["email"] as! String
    completed = snapshotValue["completed"] as! Bool
    ref = snapshot.ref
  }
  
  func toAnyObject() -> Any {
    return [
      "day": day,
      "dayIndex": dayIndex,
      "scoreAppOpened": scoreAppOpened,
      "scoreExercized": scoreExercized,
      "scoreAteHealthy": scoreAteHealthy,
      "weight": weight,
      "weightTrendisUp": weightTrendisUp,
      "isItWeekDivider": isItWeekDivider,
      "email": email,
      "completed": completed
    ]
  }
  
}




