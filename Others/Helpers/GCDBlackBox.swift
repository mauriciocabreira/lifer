//
//  GCDBlackBox.swift
//  


import UIKit


func performUIUpdatesOnMain(_ updates: @escaping () -> Void) {
    DispatchQueue.main.async {
        updates()
    }
}




