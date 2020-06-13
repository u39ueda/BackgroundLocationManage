//
//  LocationLog.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/11.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class LocationLog: Object {

    // MARK: CLLocation Properties

    /// 緯度
    @objc dynamic
    var latitude: Double = 0.0
    /// 経度
    @objc dynamic
    var longitude: Double = 0.0
    /// 標高
    @objc dynamic
    var altitude: Double = 0.0
    /// 水平精度[m]
    ///
    /// 値が小さい程正確.
    /// 負の値の場合は水平方向の値は無効.
    @objc dynamic
    var horizontalAccuracy: Double = -1.0
    /// 垂直精度[m]
    ///
    /// 値が小さい程正確.
    /// 負の値の場合は垂直方向の値は無効.
    @objc dynamic
    var verticalAccuracy: Double = -1.0
    /// 進路 (真北の度数)[degree]
    ///
    /// 0.0 - 359.9 degrees
    /// 負の値の場合は無効.
    @objc dynamic
    var course: Double = -1.0
    /// 進路の精度[degree]
    ///
    /// 値が小さい程正確.
    /// 負の値の場合は進路の値は無効.
    @objc dynamic
    var courseAccuracy: Double = -1.0
    /// 速度[m/s]
    /// 負の値の場合は無効.
    @objc dynamic
    var speed: Double = -1.0
    /// 速度の精度[m/s]
    /// 負の値の場合は速度の値は無効.
    @objc dynamic
    var speedAccuracy: Double = -1.0
    /// 位置情報を取得したタイムスタンプ
    @objc dynamic
    var timestamp: Date = Date()
    /// フロア
    ///
    /// nilの場合はフロア不明.
    let floorLevel = RealmOptional<Int32>()
    /// 位置情報を保存したタイムスタンプ
    @objc dynamic
    var createdDate: Date = Date()

    // MARK: init

    convenience init(_ location: CLLocation, createdAt createdDate: Date) {
        self.init()
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
        self.verticalAccuracy = location.verticalAccuracy
        self.course = location.course
        if #available(iOS 13.4, *) {
            self.courseAccuracy = location.courseAccuracy
        }
        self.speed = location.speed
        self.speedAccuracy = location.speedAccuracy
        self.timestamp = location.timestamp
        if let floor = location.floor {
            self.floorLevel.value = Int32(floor.level)
        }
        self.createdDate = createdDate
    }

    // MARK: Object

    override class func indexedProperties() -> [String] {
        return ["timestamp"]
    }

}

extension KeyPath where Root == LocationLog {
    var stringValue: String {
        switch self {
        case \LocationLog.latitude: return "latitude"
        case \LocationLog.longitude: return "longitude"
        case \LocationLog.altitude: return "altitude"
        case \LocationLog.horizontalAccuracy: return "horizontalAccuracy"
        case \LocationLog.verticalAccuracy: return "verticalAccuracy"
        case \LocationLog.course: return "course"
        case \LocationLog.courseAccuracy: return "courseAccuracy"
        case \LocationLog.speed: return "speed"
        case \LocationLog.speedAccuracy: return "speedAccuracy"
        case \LocationLog.timestamp: return "timestamp"
        case \LocationLog.floorLevel: return "floorLevel"
        case \LocationLog.createdDate: return "createdDate"
        default: fatalError("unknown keypath. \(self)")
        }
    }
}
