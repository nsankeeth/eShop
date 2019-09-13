//
//  Item.swift
//  eShop
//
//  Created by Sankeeth Naguleswaran on 9/13/19.
//  Copyright © 2019 SE. All rights reserved.
//

import Foundation

class Item {
    
    var title: String
    var imageURL: String
    var description: String
    var price: String
    var latitude: String
    var longitude: String
    
    init(itemTitle: String, itemImageURL: String, itemDescription: String, itemPrice: String, itemLatitude: String, itemLongitude: String) {
        
        title = itemTitle
        imageURL = itemImageURL
        description = itemDescription
        price = itemPrice
        latitude = itemLatitude
        longitude = itemLongitude
        
    }
    
}
