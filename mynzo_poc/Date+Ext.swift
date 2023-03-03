//
//  Created by Mac on 02/01/23.
//

import Foundation

enum CustomDateFormatterType {
  case type1
  case type2
  case type3
  
  var value: String {
    switch self {
    case .type1: return "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    case .type2: return "yyyy-MM-dd'T'HH:mm:ssZ"
    case .type3: return "YYYY/MM/dd HH:mm:ss"
    }
  }
}

extension Date {
  func toString(format: CustomDateFormatterType = .type3) -> String {
    let dateFormatter = DateFormatter()
    let timezone = TimeZone.current.abbreviation() ?? "CET"
    dateFormatter.timeZone = TimeZone(abbreviation: timezone)
    dateFormatter.locale = Locale(identifier: "en_US")
    dateFormatter.dateFormat = format.value
    return dateFormatter.string(from: self)
  }
  
  func component(_ component: Calendar.Component) -> Int {
    Calendar.current.component(component, from: self)
  }
}

extension Date {
  static var currentTimeStamp: Int64 {
    return Int64(Date().timeIntervalSince1970 * 1000)
  }
  
  init(milliseconds: Int64) {
    self = Date(timeIntervalSince1970: TimeInterval(milliseconds / 1000))
  }
}
