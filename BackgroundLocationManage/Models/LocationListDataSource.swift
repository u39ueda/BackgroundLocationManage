//
//  LocationListDataSource.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/29.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import Foundation
import RealmSwift

protocol LocationListViewProtocol: class {
    func deleteLocations(_ indexes: [Int])
    func insertLocations(_ indexes: [Int])
    func reloadLocations(_ indexes: [Int])
    func reloadLocations()
    func reloadData()
}

class LocationListDataSource {

    struct ViewRecord {
        var latitude: Double
        var longitude: Double
        var timestamp: Date
        var createdDate: Date
    }

    weak var view: LocationListViewProtocol?
    var dateYmd: String?

    private let locationLogRepository: LocationLogRepository
    private var fetchResults: Results<LocationLog>?
    private var locationList = [ViewRecord]()
    private var notificationToken: NotificationToken? = nil

    init(locationLogRepository: LocationLogRepository = .shared) {
        self.locationLogRepository = locationLogRepository
    }

    private func onLogListChange(_ change: RealmCollectionChange<Results<LocationLog>>) {
        switch change {
        case .initial(let result):
            log.info("LocationList initialized.")
            let locationList = self.reloadLocationList(result: result)

            DispatchQueue.main.async {
                self.locationList = locationList

                self.view?.reloadData()
                self.view?.reloadLocations()
            }
        case let .update(result, deletions, insertions, modifications):
            log.info("LocationList updated. deletions=\(deletions), insertions=\(insertions), modifications=\(modifications)")
            let locationList = self.reloadLocationList(result: result)

            DispatchQueue.main.async {
                self.locationList = locationList

                self.view?.reloadData()
                // refresh markers
                self.view?.deleteLocations(deletions)
                self.view?.insertLocations(insertions)
                self.view?.reloadLocations(modifications)
            }
        case let .error(error):
            log.info("LocationList error. \(error)")
        }
    }

    func setDateYmd(_ dateYmd: String) {
        log.info("\(dateYmd)")
        // clear previous list
        self.fetchResults = nil
        self.notificationToken = nil

        self.dateYmd = dateYmd

        if let (fromDate, toDate) = self.datesFromDateYmd(dateYmd) {
            let fetchResults = locationLogRepository.fetchList(from: fromDate, to: toDate)
            self.fetchResults = fetchResults
            self.notificationToken = fetchResults.observe(on: DispatchQueue(label: "LocationListDataSource")) { [weak self] (change) in
                guard let self = self else { return }
                self.onLogListChange(change)
            }
        }
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(inSection section: Int) -> Int {
        return locationList.count
    }

    func rowData(at indexPath: IndexPath) -> ViewRecord {
        return locationList[indexPath.row]
    }

    func mainText(_ rowData: ViewRecord) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: rowData.createdDate)
    }
    func subText(_ rowData: ViewRecord) -> String {
        return String(format: "%.6f, %.6f", rowData.latitude, rowData.longitude)
    }

    private func datesFromDateYmd(_ dateYmd: String) -> (Date, Date)? {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyyMMdd"
        if let fromDate = formatter.date(from: dateYmd),
            let toDate = Calendar.current.date(byAdding: DateComponents(day: 1), to: fromDate) {
            return (fromDate, toDate)
        } else {
            return nil
        }
    }

    private func reloadLocationList(result: Results<LocationLog>) -> [ViewRecord] {
        return result.map({ (locationLog) -> ViewRecord in
            return ViewRecord(latitude: locationLog.latitude,
                                  longitude: locationLog.longitude,
                                  timestamp: locationLog.timestamp,
                                  createdDate: locationLog.createdDate)
        })
    }

}
