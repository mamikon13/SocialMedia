//
//  DateExt.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 16/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import Foundation


extension Date {
    
    /// Creates a date from the given string.
    ///
    /// - Parameters:
    ///   - string: The string to convert to a date.
    ///   - format: The date format like that "dd.MM.yyyy".
    init(string: String, format: String = "dd.MM.yyyy") {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        self = dateFormatter.date(from: string) ?? Date.init(timeIntervalSince1970: 0)
    }
    
}
