//
//  MapViewController.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/01.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class MapViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    /// tableViewの下部マージン制約.
    /// ActiveにするとtableViewが表示され、InactiveにするとtableViewが下に隠れる.
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!

    private var dataSource: LocationListDataSource?
    private var dateYmd: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.dataSource = LocationListDataSource()
        self.dataSource?.view = self
        if let dateYmd = self.dateYmd {
            self.dataSource?.setDateYmd(dateYmd)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    func setDateYmd(_ dateYmd: String) {
        log.info("\(dateYmd)")
        self.dateYmd = dateYmd
        self.dataSource?.setDateYmd(dateYmd)
    }

}

// MARK: - UITableViewDataSource

extension MapViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let dataSource = self.dataSource else {
            return 0
        }
        return dataSource.numberOfSections()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else {
            return 0
        }
        return dataSource.numberOfRows(inSection: section)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)
        if let dataSource = self.dataSource {
            let rowData = dataSource.rowData(at: indexPath)
            cell.textLabel?.text = dataSource.mainText(rowData)
            cell.detailTextLabel?.text = dataSource.subText(rowData)
        }
        return cell
    }
}

// MARK: - UITableViewDelegate

extension MapViewController: UITableViewDelegate {

}

// MARK: - LocationListViewProtocol

extension MapViewController: LocationListViewProtocol {
    func reloadData() {
        guard isViewLoaded else {
            log.info("view unloaded.")
            return
        }
        tableView.reloadData()
    }
}
