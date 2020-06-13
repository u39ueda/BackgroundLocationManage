//
//  DateListViewController.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/01.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class DateListViewController: UITableViewController {

    private var dataSource: DateListDataSource?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

        self.dataSource = DateListDataSource()
        self.dataSource?.view = self
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        guard let dataSource = self.dataSource else {
            return 0
        }
        return dataSource.numberOfSections()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let dataSource = self.dataSource else {
            return 0
        }
        return dataSource.numberOfRows(inSection: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath)

        if let dataSource = self.dataSource {
            let rowData = dataSource.rowData(at: indexPath)
            let latlon = String(format: "%.4lf, %.4lf", rowData.latitude, rowData.longitude)
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            dateFormatter.timeStyle = .medium
            cell.textLabel?.text = "\(latlon) - \(dateFormatter.string(from: rowData.createdDate))"
        }

        return cell
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - DateListViewController

extension DateListViewController: DateListViewProtocol {
    func update(_ block: () -> Void) {
        tableView.beginUpdates()
        block()
        tableView.endUpdates()
    }

    func deleteRows(_ indexPaths: [IndexPath]) {
        guard !indexPaths.isEmpty else { return }
        tableView.deleteRows(at: indexPaths, with: .none)
    }
    func insertRows(_ indexPaths: [IndexPath]) {
        guard !indexPaths.isEmpty else { return }
        tableView.insertRows(at: indexPaths, with: .none)
    }
    func reloadRows(_ indexPaths: [IndexPath]) {
        guard !indexPaths.isEmpty else { return }
        tableView.reloadRows(at: indexPaths, with: .automatic)
    }
}
