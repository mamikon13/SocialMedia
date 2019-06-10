//
//  CustomizedDateFormatter.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 30/05/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import UIKit


class CustomizedDateFormatter: DateFormatter {
    
    static private let dateFormatter = DateFormatter()
    
    
    class func fromStringToDate(date stringDate: String, dateFormat: String = "dd.MM.yyyy") -> Date? {
        self.dateFormatter.dateFormat = dateFormat
        return dateFormatter.date(from: stringDate)
    }
    
    
    class func fromDateToString(date: Date?, dateFormat: String = "dd.MM.yyyy") -> String? {
        self.dateFormatter.dateFormat = dateFormat
        
        guard let date = date else { return "" }
        return dateFormatter.string(from: date)
    }
    
}
