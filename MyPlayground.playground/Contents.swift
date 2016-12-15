//: Playground - noun: a place where people can play

import UIKit


let dateString  = "2015-05-19T10:00+00:00"

let dateFormatter = NSDateFormatter()

dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mmZ"
dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")


 let date =  dateFormatter.dateFromString( dateString )

date

