//
//  LocationLogRepository.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/11.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import Foundation
import RealmSwift
import CoreLocation

class LocationLogRepository {

    static let shared = LocationLogRepository()

    init() {
    }

    func insert(locations: [CLLocation]) {
        let createdDate = Date()
        let logs = locations.map { (location) -> LocationLog in
            return LocationLog(location, createdAt: createdDate)
        }

        do {
            let realm = try Realm()
            try realm.write {
                realm.add(logs)
            }
        } catch let error {
            log.error("書き込み失敗. error=\(error)")
        }
    }

    func insert(error: Error) {
    }

    func fetchDateList() -> Results<LocationLog> {
        log.info()
        let realm = try! Realm()
        let descriptors: [SortDescriptor] = [
            SortDescriptor(keyPath: (\LocationLog.createdDate).stringValue),
            SortDescriptor(keyPath: (\LocationLog.timestamp).stringValue),
        ]
        return realm.objects(LocationLog.self)
            .sorted(by: descriptors)
    }
}
