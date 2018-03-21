//
//  ShareCell.swift
//  DynamicFlowLayoutDemo
//
//  Created by Ivan Hahanov on 8/21/17.
//  Copyright © 2017 Applikey. All rights reserved.
//

import UIKit
//import VegaScrollFlowLayout


class ShareCell: UICollectionViewCell {

  
  //MARK: Variables:
  let appDelegate = UIApplication.shared.delegate as! AppDelegate

  
  // MARK: Outlets
  @IBOutlet weak var journeyDayLabel: UILabel!
  @IBOutlet weak var weightLabel: UILabel!
  @IBOutlet weak var phraseLabel: UILabel!
  
  @IBOutlet weak var appOpenedImage: UIImageView!
  @IBOutlet weak var exercizedImage: UIImageView!
  @IBOutlet weak var ateWellImage: UIImageView!
  @IBOutlet weak var doneImage: UIImageView!
  @IBOutlet weak var tendencyIcon: UIImageView!
  
  @IBOutlet private weak var priceLabel: UILabel!

	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		phraseLabel.textColor = UIColor.vegaGray
		layer.cornerRadius = 14
		layer.shadowColor = UIColor.black.cgColor
		layer.shadowOpacity = 0.3
		layer.shadowOffset = CGSize(width: 0, height: 5)
		layer.masksToBounds = false
	}
	
  func doubleABiggerThanB(_ a: Double, _ b: Double) -> Bool {
    return fabs(a - b) < Double .ulpOfOne
  }
  
	func configureWith(_ day: Days) {
    journeyDayLabel.text = day.day
    phraseLabel.text = day.email
    
    print("(ShareCell)Day: \(day)")
    tendencyIcon.image = nil
    weightLabel.text = ""
    phraseLabel.text = ""
    priceLabel.text = ""
    
    if day.weight != "0" && day.weight != "" {
      if day.dayIndex != 0 {
        
        if day.weightTrendisUp {
          weightLabel.textColor = UIColor.vegaRed

          phraseLabel.text = "Peso 📈🔺 🤦🏻‍♀️🤦🏼‍♂️"
        } else {
          phraseLabel.text = "Peso 📉 Yes! 🍾"
          weightLabel.textColor = UIColor.vegaGreen
 }
      }
      weightLabel.text = day.weight + "Kg"
  
    }
  
    appOpenedImage.image = day.scoreAppOpened ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    exercizedImage.image = day.scoreExercized ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    ateWellImage.image = day.scoreAteHealthy ? #imageLiteral(resourceName: "star_done") : #imageLiteral(resourceName: "star_missed")
    
    if day.completed {
      doneImage.image = #imageLiteral(resourceName: "done")
      journeyDayLabel?.textColor = UIColor.vegaGreen
      phraseLabel?.textColor = UIColor.vegaGreen
      //weightLabel.textColor = UIColor.vegaGreen
      
    } else {
      doneImage.image = nil
      journeyDayLabel?.textColor = UIColor.lightGray
      phraseLabel?.textColor = UIColor.lightGray
      //weightLabel.textColor = UIColor.lightGray
    }
	}
	
	private func twoDigitsFormatted(_ val: Double) -> String {
		return String(format: "%.0.2f", val)
	}
}
