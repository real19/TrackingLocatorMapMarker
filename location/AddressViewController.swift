//
//  AddressViewController.swift
//  location
//
//  Created by Imdad, Suleman on 7/12/18.
//  Copyright © 2018 Imdad, Suleman. All rights reserved.
//

import UIKit
import CoreLocation

class AddressViewController: UIViewController {

    lazy var geocoder = CLGeocoder()
    
    var coordinate:CLLocationCoordinate2D?
    
    @IBOutlet weak var addressLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        guard let coordinate = coordinate else {
            return
        }
        
        getAddressFor(coordinate: coordinate)
    }
    
    func getAddressFor (coordinate:CLLocationCoordinate2D){
        // Create Location
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        // Geocode Location
        geocoder.reverseGeocodeLocation(location) {[weak self] (placemarks, error) in
            // Process Response
            
            if error == nil {
                self?.addressLabel.text = placemarks?.first?.getAddress
            }
        }
    }

    
  
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
