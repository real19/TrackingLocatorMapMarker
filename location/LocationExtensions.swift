//
//  test.swift
//  location
//
//  Created by Imdad, Suleman on 7/12/18.
//  Copyright © 2018 Imdad, Suleman. All rights reserved.
//

import Foundation
import CoreData
import CoreLocation

extension Location{
    
    static func fetchAll(context:NSManagedObjectContext) -> ([Location]?) {
        let locationsFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Location")
        locationsFetch.sortDescriptors = [NSSortDescriptor.init(key: "timestamp", ascending: false)]
        
        guard let locations = try? context.fetch(locationsFetch) else {
            return nil
        }
        return locations as? [Location]
    }
    
     func coordinate()->CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

extension CLPlacemark {
    
    var getAddress: String? {
        if let name = name {
            var result = name
            
            if let street = thoroughfare {
                result += ", \(street)"
            }
            
            if let city = locality {
                result += ", \(city)"
            }
            
            if let country = country {
                result += ", \(country)"
            }
            
            return result
        }
        
        return nil
    }
    
}

