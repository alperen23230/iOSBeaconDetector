//
//  ViewController.swift
//  BeaconDetector
//
//  Created by Alperen Ünal on 19.04.2019.
//  Copyright © 2019 Alperen Ünal. All rights reserved.
//

import UIKit
import CoreLocation
import UserNotifications

class ViewController: UIViewController, CLLocationManagerDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet var distanceReading: UILabel!
    let locationManager = CLLocationManager()
    
    var beaconRegion: CLBeaconRegion!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted? \(granted)")
        }
        UNUserNotificationCenter.current().delegate = self
        
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        
        let uuid = UUID(uuidString: "6fd8c37b-ebf6-43ae-b2eb-343e9c2730c4")!
        beaconRegion = CLBeaconRegion(proximityUUID: uuid, major: 3755, minor: 10926, identifier: uuid.uuidString)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyEntryStateOnDisplay = true
        
        if CLLocationManager.authorizationStatus() != .authorizedAlways {
            locationManager.requestAlwaysAuthorization()
        } else {
            locationManager.startMonitoring(for: beaconRegion)
        }
        
        view.backgroundColor = .gray
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways:
            if !locationManager.monitoredRegions.contains(beaconRegion) {
                locationManager.startMonitoring(for: beaconRegion)
            }
        case .authorizedWhenInUse:
            if !locationManager.monitoredRegions.contains(beaconRegion) {
                locationManager.startMonitoring(for: beaconRegion)
            }
        default:
            print("authorisation not granted")
        }
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        print("Did determine state for region \(region)")
        if state == .inside {
            locationManager.startRangingBeacons(in: beaconRegion)
        } else {
            postNotification(withBody: "outside")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        print("Did start monitoring region: \(region)\n")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        postNotification(withBody: "Enter")
        locationManager.startRangingBeacons(in: beaconRegion)
        print("didEnter")
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        postNotification(withBody: "Exit")
        locationManager.stopRangingBeacons(in: beaconRegion)
        print("didExit")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        if beacons.count > 0 {
            update(distance: beacons[0].proximity)
            print(beacons[0].accuracy)
            print(beacons[0].rssi)
        } else {
            update(distance: .unknown)
        }
    }
    
    
    func update(distance: CLProximity){
        UIView.animate(withDuration: 0.8){
            switch distance {
            case .far:
                self.view.backgroundColor = UIColor.blue
                self.distanceReading.text = "FAR"
                print("far")
                
            case .near:
                self.view.backgroundColor = UIColor.orange
                self.distanceReading.text = "NEAR"
                print("near")
            case .immediate:
                self.view.backgroundColor = UIColor.red
                self.distanceReading.text = "RIGHT HERE"
                print("immediate")
            default:
                self.view.backgroundColor = UIColor.gray
                self.distanceReading.text = "UNKNOWN"
                print("Unknown")
            }
        }
    }
    
    
    func postNotification(withBody body: String) {
        let content = UNMutableNotificationContent()
        content.title = body
        content.body = body
        content.sound = UNNotificationSound.default
        let request = UNNotificationRequest(identifier: "EntryNotification", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(.alert)
    }
    
    
}

