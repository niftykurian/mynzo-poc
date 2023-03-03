//
//  Created by Mac on 02/01/23.
//

import Foundation

//MARK: -

let kLogsFile = "TestingLogs"
let kBGActivitiesLogsFile = "BGActivitiesLogs"
let kSendEventsLogsFile = "SendEventsLogsFile"
let kLogsDirectory = "TestingLogsData"

@objc @objcMembers final class Logger: NSObject {
  static let shared = Logger()
  private override init() {}
  
  
  class func write(text: String, to fileNamed: String = kLogsFile, folder: String = kLogsDirectory) {
#if DEBUG
    let textToBeAppended = "\n\(Date().toString()) "+text+"\n"
    guard let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first else { return }
    guard let writePath = NSURL(fileURLWithPath: path).appendingPathComponent(folder) else { return }
    //print(writePath.absoluteString)
    let file = writePath.appendingPathComponent(fileNamed + ".txt")
    
    if let fileHandle = FileHandle(forWritingAtPath: file.path) {
      fileHandle.seekToEndOfFile()
      fileHandle.write(textToBeAppended.data(using: .utf8)!)
    } else {
      print("File doesn't exists")
      try? FileManager.default.createDirectory(atPath: writePath.path, withIntermediateDirectories: true)
      try? textToBeAppended.write(to: file, atomically: false, encoding: String.Encoding.utf8)
    }
#endif
  }
  
  
  func printOnConsole(_ value: Any...) {
#if DEBUG
    debugPrint()
    printValue(value)
    debugPrint()
#endif
  }
  
  private func printValue(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    var idx = items.startIndex
    let endIdx = items.endIndex
    repeat {
      Swift.print(items[idx], separator: separator, terminator: idx == (endIdx - 1) ? terminator : separator)
      idx += 1
    }
    while idx < endIdx
  }
}
