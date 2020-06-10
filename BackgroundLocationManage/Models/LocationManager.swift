//
//  LocationManager.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/01.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import Foundation
import CoreLocation

final class LocationManager {
    private let locationManager = CLLocationManager()
    private let proxy = LocationManagerProxy()

    public static let shared = LocationManager()

    init() {
        /// 循環参照を避けるためにdelegateは自身ではなくProxyオブジェクトを経由する
        self.proxy.owner = self
        self.locationManager.delegate = self.proxy

        // 更新に関連するユーザのアクテビティ
        self.locationManager.activityType = .other
        // 測位の精度を指定(約3kmごと。3km以下の移動でも、位置情報が通知されることが多々ある)
        self.locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        // 位置情報取得間隔を指定(10m移動したら、位置情報を通知)
        self.locationManager.distanceFilter = 100
        // 自動で位置情報取得がOFFになるのを防ぐ
        self.locationManager.pausesLocationUpdatesAutomatically = false
        // バックグランドでも位置情報を取得
        self.locationManager.allowsBackgroundLocationUpdates = true
    }

    func startUpdate() {
        if CLLocationManager.authorizationStatus() == .notDetermined {
            log.info("requestAlwaysAuthorization()")
            self.locationManager.requestAlwaysAuthorization()
            return
        }
        if !CLLocationManager.locationServicesEnabled() {
            log.info("locationServicesEnabled() disabled")
            return
        }
        log.info()
        self.locationManager.startUpdatingLocation()
        startMonitoringSignificantLocationChanges()
    }

    func stopUpdate() {
        log.info()
        self.locationManager.stopUpdatingLocation()
    }

    func startMonitoringSignificantLocationChanges() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            log.info("significantLocationChangeMonitoringAvailable unailable")
            return
        }
        log.info()
        self.locationManager.startMonitoringSignificantLocationChanges()
    }

    func stopMonitoringSignificantLocationChanges() {
        if !CLLocationManager.significantLocationChangeMonitoringAvailable() {
            log.info("significantLocationChangeMonitoringAvailable unailable")
            return
        }
        log.info()
        self.locationManager.stopMonitoringSignificantLocationChanges()
    }
}

// MARK: CLLocationManagerDelegate

extension LocationManager {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            log.info("notDetermined")
        case .restricted:
            log.info("restricted")
        case .denied:
            log.info("denied")
        case .authorizedAlways:
            log.info("authorizedAlways")
        case .authorizedWhenInUse:
            log.info("authorizedWhenInUse")
            self.startUpdate()
        @unknown default:
            log.info("unknown. status=\(status.rawValue)")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        log.info("位置情報更新. locations=\(locations)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        log.info("位置情報失敗. error=\(error)")
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        log.info("位置情報ポーズ")
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        log.info("位置情報レジューム")
    }
}

private class LocationManagerProxy: NSObject {

    weak var owner: LocationManager?

}

// MARK: CLLocationManagerDelegate

extension LocationManagerProxy: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        owner?.locationManager(manager, didChangeAuthorization: status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        owner?.locationManager(manager, didUpdateLocations: locations)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        owner?.locationManager(manager, didFailWithError: error)
    }

    func locationManagerDidPauseLocationUpdates(_ manager: CLLocationManager) {
        owner?.locationManagerDidPauseLocationUpdates(manager)
    }

    func locationManagerDidResumeLocationUpdates(_ manager: CLLocationManager) {
        owner?.locationManagerDidResumeLocationUpdates(manager)
    }
}
