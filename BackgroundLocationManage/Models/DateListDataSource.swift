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
}

class DateListDataSource {

    weak var view: DateListViewProtocol?

    private let locationLogRepository: LocationLogRepository
    private let dateList: Results<LocationLog>
    private var notificationToken: NotificationToken? = nil

    init (locationLogRepository: LocationLogRepository = .shared) {
        self.locationLogRepository = locationLogRepository

        self.dateList = locationLogRepository.fetchDateList()
        self.notificationToken = self.dateList.observe { [weak self] (change) in
            guard let self = self else { return }
            self.onDateListChange(change)
        }
    }

    private func onDateListChange(_ change: RealmCollectionChange<Results<LocationLog>>) {
        switch change {
        case .initial:
            log.info("DateList initialized.")
        case let .update(_, deletions, insertions, modifications):
            log.info("DateList updated. deletions=\(deletions), insertions=\(insertions), modifications=\(modifications)")
            if let view = view {
                view.update {
                    view.deleteRows(deletions.map({ IndexPath(row: $0, section: 0) }))
                    view.insertRows(insertions.map({ IndexPath(row: $0, section: 0) }))
                    view.reloadRows(modifications.map({ IndexPath(row: $0, section: 0) }))
                }
            }
        case let .error(error):
            log.info("DateList error. \(error)")
        }
    }

    func numberOfSections() -> Int {
        return 1
    }

    func numberOfRows(inSection section: Int) -> Int {
        return dateList.count
    }

    func rowData(at indexPath: IndexPath) -> LocationLog {
        return dateList[indexPath.row]
    }

}
