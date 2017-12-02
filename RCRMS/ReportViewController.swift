//
//  ReportViewController.swift
//  RCRMS
//
//  Created by Wei Qian on 11/11/17.
//  Copyright © 2017 Wei Qian. All rights reserved.
//

import UIKit
import GoogleMaps
import Firebase
import FirebaseDatabase
import CoreLocation

class ReportViewController: UIViewController,UITableViewDelegate,UITableViewDataSource,CLLocationManagerDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var titles:Array = [String]()
    var contents:Array = [String]()
    
    var GPS:String=""
    var road:String=""
    var name:String=""
    var email:String=""
    
    var connect:Bool=false
    
    var locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        titles=["GPS*","Road*","Name*","Email*"]
        contents=["GPS location","Road name","Your name","Email address"]
        
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ReportViewController.back(sender:)))
        self.navigationItem.title="Report"
        let sendButton = UIBarButtonItem(title:"Send", style:UIBarButtonItemStyle.plain, target: self, action: #selector(ReportViewController.send(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
        self.navigationItem.rightBarButtonItem=sendButton
        
        if CLLocationManager.locationServicesEnabled(){
            locationManager.delegate=self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,   didUpdateLocations locations: [CLLocation]) {
        let locValue:CLLocationCoordinate2D = manager.location!.coordinate
        
        let indexGPS=IndexPath(row: 0, section: 0)
        let cellGPS=tableView.cellForRow(at: indexGPS) as! ReportTableViewCell
        cellGPS.tfContent.text!="\(locValue.latitude) \(locValue.longitude)"
    }
    
    @objc func back(sender: UIBarButtonItem) {
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let resultViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
        self.present(resultViewController, animated:true, completion:nil)

    }
    
    @objc func send(sender: UIBarButtonItem) {
        getText()
        if(GPS=="" || road=="" || name=="" || email=="")
        {
            let alertController = UIAlertController(title: "Oops", message: "All information required!", preferredStyle: UIAlertControllerStyle.alert)
            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                (result : UIAlertAction) -> Void in
                print("OK")
            }
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }
        else
        {
            let ref=Database.database().reference().child("Live")
            let key=ref.childByAutoId().key
            let comp:Dictionary! = ["id":key,"GPS":self.GPS,
                                    "road":self.road,
                                    "name":self.name,
                                    "email":self.email]
            ref.child(key).setValue(comp)
            
            let sentController = UIAlertController(title: "Report Sent!", message: nil, preferredStyle: UIAlertControllerStyle.alert)
            self.present(sentController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.presentedViewController?.dismiss(animated: false, completion: nil)
                
                let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
                let resultViewController = storyBoard.instantiateViewController(withIdentifier: "SWRevealViewController") as! SWRevealViewController
                self.present(resultViewController, animated:true, completion:nil)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportTableViewCell") as! ReportTableViewCell
        cell.lbTitle.text!=titles[indexPath.row]
        cell.tfContent.placeholder=contents[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    func getText(){
        let indexGPS=IndexPath(row: 0, section: 0)
        let cellGPS=tableView.cellForRow(at: indexGPS) as! ReportTableViewCell
        GPS = cellGPS.tfContent.text!
        
        let indexRoad=IndexPath(row: 1, section: 0)
        let cellRoad=tableView.cellForRow(at: indexRoad) as! ReportTableViewCell
        road = cellRoad.tfContent.text!
        
        let indexName=IndexPath(row: 2, section: 0)
        let cellName=tableView.cellForRow(at: indexName) as! ReportTableViewCell
        name = cellName.tfContent.text!
        
        let indexEmail=IndexPath(row: 3, section: 0)
        let cellEmail=tableView.cellForRow(at: indexEmail) as! ReportTableViewCell
        email = cellEmail.tfContent.text!
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
}
