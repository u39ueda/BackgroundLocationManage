//
//  DateListDataSource.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/13.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import Foundation
import RealmSwift

protocol DateListViewProtocol: class {
    func update(_ block: () -> Void)
    func deleteRows(_ indexPaths: [IndexPath])
    func insertRows(_ indexPaths: [IndexPath])
    func reloadRows(_ indexPaths: [IndexPath])
    func reloadData()
}

class DateListDataSource {

    struct DateRecord {
        var dateYmd: String
        var count: Int
    }

    weak var view: DateListViewProtocol?

    private let locationLogRepository: LocationLogRepository
    private let dateList: Results<LocationLog>
    private var dateYmdList = [DateRecord]()
    private var notificationToken: NotificationToken? = nil

    init (locationLogRepository: LocationLogRepository = .shared) {
        self.locationLogRepository = locationLogRepository

        self.dateList = locationLogRepository.fetchDateList()
        self.notificationToken = self.dateList.observe(on: DispatchQueue(label: "DateListDataSource")) { [weak self] (change) in
            guard let self = self else { return }
            self.onDateListChange(change)
        }
    }

    private func onDateListChange(_ change: RealmCollectionChange<Results<LocationLog>>) {
        switch change {
        case .initial(let result):
            log.info("DateList initialized.")
            let dateYmdList = self.reloadDateMap(result: result)

            DispatchQueue.main.async {
                self.dateYmdList = dateYmdList

                self.view?.reloadData()
            }
        case let .update(result, deletions, insertions, modifications):
            log.info("DateList updated. deletions=\(deletions), insertions=\(insertions), modifications=\(modifications)")
            let dateYmdList = self.reloadDateMap(result: result)

            DispatchQueue.main.async {
                self.dateYmdList = dateYmdList

                self.view?.reloadData()
            }
        case let .error(error):
            log.info("DateList error. \(error)")
        }
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(inSection section: Int) -> Int {
        return dateYmdList.count
    }

    func rowData(at indexPath: IndexPath) -> DateRecord {
        return dateYmdList[indexPath.row]
    }

    private func reloadDateMap(result: Results<LocationLog>) -> [DateRecord] {
        var dateMap = [String: Int]()
        result.forEach { (locationLog) in
            let createdDate = locationLog.createdDateYmd(timeZone: .current)
            dateMap[createdDate] = dateMap[createdDate, default: 0] + 1
        }
        let dateYmdList = dateMap.keys.sorted().map({ (dateYmd) in
            return DateRecord(dateYmd: dateYmd,
                              count: dateMap[dateYmd, default: 0])
        })
        return dateYmdList
    }

}
