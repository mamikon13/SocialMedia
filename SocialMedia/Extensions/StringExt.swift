//
//  String.swift
//  SocialMedia
//
//  Created by Mamikon Nikogosyan on 16/06/2019.
//  Copyright © 2019 Mamikon Nikogosyan. All rights reserved.
//

import Foundation


extension String {
    
    /// Creates a string from the given date.
    ///
    /// - Parameters:
    ///   - date: The date to convert to a string.
    ///   - format: The date format like that "dd.MM.yyyy".
    init(date: Date?, format: String = "dd.MM.yyyy") {
        guard let date = date else {
            self = ""
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        
        self = dateFormatter.string(from: date)
    }
    
}
