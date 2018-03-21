//
//  JourneyViewController.swift
//  Lifer
//
//  Created by Mauricio Cabreira on 27/02/18.
//  Copyright © 2018 Mauricio Cabreira. All rights reserved.
//

import UIKit
import VegaScrollFlowLayout
import Firebase
import UserNotifications


class JourneyViewController: UIViewController {
 
  // MARK: - Configurable constants
  fileprivate let cellId = "ShareCell"
 private let itemHeight: CGFloat = 84
  private let lineSpacing: CGFloat = 20
  private let xInset: CGFloat = 20
  private let topInset: CGFloat = 10
  let segueToChat = "JourneyToChat"
  let segueToOptions = "OptionsViewController"
  
  var selectedDay: Int = 0
  private lazy var channelRef: DatabaseReference = Database.database().reference().child("channels")
  
  
  
  
  fileprivate var days: [Days] = []
  let appDelegate = UIApplication.shared.delegate as! AppDelegate
  var currentDay: Int = 0
  
  // MARK: Outlets
  
  @IBOutlet private weak var collectionView: UICollectionView!
  
  @IBOutlet weak var star_checkin1: UIImageView!
  @IBOutlet weak var star_checkin2: UIImageView!
  @IBOutlet weak var star_checkin3: UIImageView!
  @IBOutlet weak var star_checkin4: UIImageView!
  @IBOutlet weak var star_checkin5: UIImageView!
  @IBOutlet weak var star_checkin6: UIImageView!
  @IBOutlet weak var star_checkin7: UIImageView!
  @IBOutlet weak var star_checkin8: UIImageView!
  @IBOutlet weak var star_checkin9: UIImageView!
  @IBOutlet weak var star_checkin10: UIImageView!
  @IBOutlet weak var star_checkin11: UIImageView!
  @IBOutlet weak var star_checkin12: UIImageView!
  @IBOutlet weak var star_checkin13: UIImageView!
  @IBOutlet weak var star_checkin14: UIImageView!
  @IBOutlet weak var star_checkin15: UIImageView!
  @IBOutlet weak var star_checkin16: UIImageView!
  @IBOutlet weak var star_checkin17: UIImageView!
  @IBOutlet weak var star_checkin18: UIImageView!
  @IBOutlet weak var star_checkin19: UIImageView!
  @IBOutlet weak var star_checkin20: UIImageView!
  @IBOutlet weak var star_checkin21: UIImageView!
  
  @IBOutlet weak var star_exercized_1: UIImageView!
  @IBOutlet weak var star_exercized_2: UIImageView!
  @IBOutlet weak var star_exercized_3: UIImageView!
  @IBOutlet weak var star_exercized_4: UIImageView!
  @IBOutlet weak var star_exercized_5: UIImageView!
  @IBOutlet weak var star_exercized_6: UIImageView!
  @IBOutlet weak var star_exercized_7: UIImageView!
  @IBOutlet weak var star_exercized_8: UIImageView!
  @IBOutlet weak var star_exercized_9: UIImageView!
  @IBOutlet weak var star_exercized_10: UIImageView!
  @IBOutlet weak var star_exercized_11: UIImageView!
  @IBOutlet weak var star_exercized_12: UIImageView!
  @IBOutlet weak var star_exercized_13: UIImageView!
  @IBOutlet weak var star_exercized_14: UIImageView!
  @IBOutlet weak var star_exercized_15: UIImageView!
  @IBOutlet weak var star_exercized_16: UIImageView!
  @IBOutlet weak var star_exercized_17: UIImageView!
  @IBOutlet weak var star_exercized_18: UIImageView!
  @IBOutlet weak var star_exercized_19: UIImageView!
  @IBOutlet weak var star_exercized_20: UIImageView!
  @IBOutlet weak var star_exercized_21: UIImageView!
  
  @IBOutlet weak var star_atewell_1: UIImageView!
  @IBOutlet weak var star_atewell_2: UIImageView!
  @IBOutlet weak var star_atewell_3: UIImageView!
  @IBOutlet weak var star_atewell_4: UIImageView!
  @IBOutlet weak var star_atewell_5: UIImageView!
  @IBOutlet weak var star_atewell_6: UIImageView!
  @IBOutlet weak var star_atewell_7: UIImageView!
  @IBOutlet weak var star_atewell_8: UIImageView!
  @IBOutlet weak var star_atewell_9: UIImageView!
  @IBOutlet weak var star_atewell_10: UIImageView!
  @IBOutlet weak var star_atewell_11: UIImageView!
  @IBOutlet weak var star_atewell_12: UIImageView!
  @IBOutlet weak var star_atewell_13: UIImageView!
  @IBOutlet weak var star_atewell_14: UIImageView!
  @IBOutlet weak var star_atewell_15: UIImageView!
  @IBOutlet weak var star_atewell_16: UIImageView!
  @IBOutlet weak var star_atewell_17: UIImageView!
  @IBOutlet weak var star_atewell_18: UIImageView!
  @IBOutlet weak var star_atewell_19: UIImageView!
  @IBOutlet weak var star_atewell_20: UIImageView!
  @IBOutlet weak var star_atewell_21: UIImageView!
  
  @IBOutlet weak var weight_day_1: UILabel!
  @IBOutlet weak var weight_day_5: UILabel!
  @IBOutlet weak var weight_day_10: UILabel!
  @IBOutlet weak var weight_day_15: UILabel!
  @IBOutlet weak var weight_day_21: UILabel!
  
  @IBOutlet weak var settingsButton: UIButton!
  
  //  MARK: Actions
  
  
 
  @IBAction func logoutUser(_ sender: Any) {
    do {
      try Auth.auth().signOut()
      
    } catch let signOutError as NSError {
      print ("Error signing out: %@", signOutError)
    }
    self.dismiss(animated: false, completion: nil)
    print("cancel")
  }
  
  
  //  MARK: Lifecycle
  override func viewDidLoad() {
    super.viewDidLoad()
    currentDay = currentDayIndex()
    print("Current journey day: \(currentDay + 1)")
   
    days = appDelegate.days
    let nib = UINib(nibName: cellId, bundle: nil)
    collectionView.register( nib, forCellWithReuseIdentifier: cellId)
    collectionView.contentInset.bottom = itemHeight
    configureCollectionViewLayout()
    setUpNavBar()

    updateDaysToCompleted()
    updateDashboard()
  }
  
  
  
  private func setUpNavBar() {
    
    navigationItem.title = "Dia " + String(currentDay + 1) + "/21"
    navigationController?.view.backgroundColor = UIColor.clear
    
    if #available(iOS 11.0, *) {
      navigationController?.navigationBar.prefersLargeTitles = false
    }
  }
  
  private func configureCollectionViewLayout() {
    guard let layout = collectionView.collectionViewLayout as? VegaScrollFlowLayout else { return }
    layout.minimumLineSpacing = lineSpacing
    layout.sectionInset = UIEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    let itemWidth = UIScreen.main.bounds.width - 2 * xInset
    layout.itemSize = CGSize(width: itemWidth, height: itemHeight)
    collectionView.collectionViewLayout.invalidateLayout()
  }
  
}


//MARK: Collection functions

extension JourneyViewController: UICollectionViewDataSource, UICollectionViewDelegate {
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ShareCell
    let day = days[indexPath.row]
    cell.configureWith(day)
    
    toggleCell(cell, isEnabled(days[indexPath.row]))
    
    return cell
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return days.count
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    //If day is either today or yesterday, and it has not been logged yet, open chat to log the day
    if isEnabled(days[indexPath.row]) {
      selectedDay = indexPath.row
      performUIUpdatesOnMain {
        self.performSegue(withIdentifier: self.segueToChat, sender: nil)
      }
    }
    
  }
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    super.prepare(for: segue, sender: sender)
    
    if segue.identifier == segueToChat {
      let navVc = segue.destination as! UINavigationController
      let chatVc = navVc.viewControllers.first as! ChatViewController
      
       chatVc.senderDisplayName = "Eu"
      let channel = Channel(id: appDelegate.currentUserData.channelId, name: appDelegate.currentUserData.email)
      chatVc.channel = channel
      chatVc.channelRef = channelRef.child(channel.id)
      
      chatVc.currentDay = selectedDay
      chatVc.chatType = ChatViewController.ChatType.askAboutTheDay
      print("senderDisplayName: \(chatVc.senderDisplayName)  Channel: \(channel) ChannelRef: \(channelRef.child(channel.id))")
    }
  }
  
 
  func isEnabled(_ day: Days) -> Bool {
    
    let todayIndex = currentDayIndex()
    if (day.dayIndex == todayIndex || day.dayIndex == (todayIndex - 1)) && !day.completed {
      return true
      
    } else {
      return false
      
    }

  }
  
  
  func toggleCell(_ cell: ShareCell, _ isEnabled: Bool) {
    
    if isEnabled {
      cell.isHighlighted = true
      //cell.isOpaque = true
      
      
      cell.journeyDayLabel?.textColor = UIColor.blue
      cell.phraseLabel?.textColor = UIColor.blue
      cell.weightLabel?.textColor = UIColor.blue
      
    } else {
      cell.isHighlighted = false
      //cell.isOpaque = false
      
    }
  }
  
  func scrollToDay(_ day: Int){
    //DispatchQueue.main.async {
    //let indexPath = IndexPath(row: day, section: 0)// (row: self.days.count-1, section: 0)
    //self.collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
    //}
  }
  
  // MARK: Navigation
  
 
  
  
}


//MARK: Dates
extension JourneyViewController {
  
  //Format a date to a specify format.
  func formattedDateFromString(_ dateString: String, withFormat format: String) -> String? {
    
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "dd/MM/yyyy"
    
    if let date = inputFormatter.date(from: dateString) {
      
      let outputFormatter = DateFormatter()
      outputFormatter.dateFormat = format
      
      return outputFormatter.string(from: date)
    }
    
    return nil
  }
  
  func returnDaysDifference(_ strDateStart : String, _ strDateEnd : String) -> Int{
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyyMMdd"
    let dateRangeStart = dateFormatter.date(from: strDateStart)!  //date format
    let dateRangeEnd = dateFormatter.date(from: strDateEnd)!  // date format
    
    
     let components = Calendar.current.dateComponents([.day], from: dateRangeStart, to: dateRangeEnd)
    
    print(dateRangeStart)
    print(dateRangeEnd)
    print("difference is \(components.day ?? 0) days")
    // print("difference is \(components.month ?? 0) months and \(components.weekOfYear ?? 0) weeks")
    
    return components.day ?? 0
  }
  
  func returnDaysDifference(_ intDateStart : Int, _ intDateEnd : Int) -> Int{
    return intDateEnd - intDateStart
  }
  
  func currentDayIndex() -> Int {
    let dateformatter = DateFormatter()
    dateformatter.dateFormat = "yyyyMMdd"
    let today = dateformatter.string(from: Date())
    return returnDaysDifference(appDelegate.currentUserData.startDate, today)
  }
}


//MARK: Updates to DB
extension JourneyViewController {
  
  // Called everytime the app is opened to update the COMPLETED checkmark ( all the days before yesterday ). COMPLETED days can't be logged by user. Just current day and day before
  func updateDaysToCompleted() {
    
    let today = currentDayIndex()
    for day in days {
      
      // it is future and it was not enabled, so it is not completed
      if day.dayIndex > today {
        print("Day is future")
        setDayTo(day, false)
        
        
      } else {
        // the day is today, yesterday or before.
        
        // If day is day-before yesterday and behind, it is auto-completed
        if day.dayIndex < (today - 1) {
          print("Day 2d ago or earlier")
          setDayTo(day, true)
        } else {
          print("Day is today or yesterday")
        }
      }
    }
    self.collectionView.reloadData()
  }
  
  
  
  
  func setDayTo(_ day: Days, _ status: Bool) {
    
    var ref: DatabaseReference!
    
    ref = Database.database().reference()
    ref.child("days/\(appDelegate.userKey)/\(day.day)/completed").setValue(status)
    days[day.dayIndex].completed = status
    print("\(day.day) set to \(days[day.dayIndex].completed)")
    
  }
  
  func updateDashboard() {
  
    star_checkin1.image = days[0].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin2.image = days[1].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin3.image = days[2].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin4.image = days[3].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin5.image = days[4].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin6.image = days[5].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin7.image = days[6].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin8.image = days[7].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin9.image = days[8].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin10.image = days[9].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin11.image = days[10].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin12.image = days[11].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin13.image = days[12].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin14.image = days[13].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin15.image = days[14].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin16.image = days[15].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin17.image = days[16].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin18.image = days[17].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin19.image = days[18].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin20.image = days[19].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_checkin21.image = days[20].scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    
    star_exercized_1.image = days[0].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_2.image = days[1].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_3.image = days[2].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_4.image = days[3].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_5.image = days[4].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_6.image = days[5].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_7.image = days[6].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_8.image = days[7].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_9.image = days[8].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_10.image = days[9].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_11.image = days[10].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_12.image = days[11].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_13.image = days[12].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_14.image = days[13].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_15.image = days[14].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_16.image = days[15].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_17.image = days[16].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_18.image = days[17].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_19.image = days[18].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_20.image = days[19].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_exercized_21.image = days[20].scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")

    star_atewell_1.image = days[0].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_2.image = days[1].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_3.image = days[2].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_4.image = days[3].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_5.image = days[4].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_6.image = days[5].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_7.image = days[6].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_8.image = days[7].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_9.image = days[8].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_10.image = days[9].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_11.image = days[10].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_12.image = days[11].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_13.image = days[12].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_14.image = days[13].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_15.image = days[14].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_16.image = days[15].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_17.image = days[16].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_18.image = days[17].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_19.image = days[18].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_20.image = days[19].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    star_atewell_21.image = days[20].scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    
    weight_day_1.text = days[0].weight
    
    if currentDay >= 4 && days[4].completed {
      
      weight_day_5.text = days[4].weight
      weight_day_5.textColor = days[4].weightTrendisUp ? UIColor.vegaRed : UIColor.vegaGreen

      if currentDay >= 9 && days[9].completed {
        weight_day_10.text = days[9].weight
        weight_day_10.textColor = days[9].weightTrendisUp ? UIColor.vegaRed : UIColor.vegaGreen
        
        if currentDay >= 14 && days[14].completed {
          weight_day_15.text = days[14].weight
          weight_day_15.textColor = days[14].weightTrendisUp ? UIColor.vegaRed : UIColor.vegaGreen
          
          if currentDay >= 20 && days[20].completed {
            weight_day_21.text = days[20].weight
            weight_day_21.textColor = days[20].weightTrendisUp ? UIColor.vegaRed : UIColor.vegaGreen
          }
        }
      }
    }
  }
  
 
}

