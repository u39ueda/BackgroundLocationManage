//
//  Logger.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/01.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import Foundation
import XCGLogger

let log: XCGLogger = createDebugLogger()

private func createDebugLogger() -> XCGLogger {
    // Create a logger object with no destinations
    let log = XCGLogger(identifier: "Logger", includeDefaultDestinations: false)

    // Create a destination for the system console log (via NSLog)
    let systemDestination = AppleSystemLogDestination(identifier: "Logger.systemDestination")

    // Optionally set some configuration options
    systemDestination.outputLevel = .debug
    systemDestination.showLogIdentifier = false
    systemDestination.showFunctionName = true
    systemDestination.showThreadName = true
    systemDestination.showLevel = true
    systemDestination.showFileName = true
    systemDestination.showLineNumber = true
    systemDestination.showDate = true

    // Add the destination to the logger
    log.add(destination: systemDestination)

    let logDirUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.dateFormat = "yyyyMMdd'_'hhmmss'.txt'"
    let logFileUrl = logDirUrl.appendingPathComponent(dateFormatter.string(from: Date()))
    // Create a file log destination
    let fileDestination = FileDestination(writeToFile: logFileUrl.path, identifier: "Logger.fileDestination")

    // Optionally set some configuration options
    fileDestination.outputLevel = .debug
    fileDestination.showLogIdentifier = false
    fileDestination.showFunctionName = true
    fileDestination.showThreadName = true
    fileDestination.showLevel = true
    fileDestination.showFileName = true
    fileDestination.showLineNumber = true
    fileDestination.showDate = true

    // Process this destination in the background
    fileDestination.logQueue = XCGLogger.logQueue

    // Add the destination to the logger
    log.add(destination: fileDestination)

    // Add basic app info, version info etc, to the start of the logs
    log.logAppDetails()

    return log
}
