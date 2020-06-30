//
//  MapViewController.swift
//  BackgroundLocationManage
//
//  Created by 植田裕作 on 2020/06/01.
//  Copyright © 2020 Yusaku Ueda. All rights reserved.
//

import UIKit
import GoogleMaps

private let reuseIdentifier = "Cell"

class MapViewController: UIViewController {

    @IBOutlet weak var mapContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    /// tableViewの下部マージン制約.
    /// ActiveにするとtableViewが表示され、InactiveにするとtableViewが下に隠れる.
    @IBOutlet weak var tableBottomConstraint: NSLayoutConstraint!

    private weak var mapView: GMSMapView!
    private var dataSource: LocationListDataSource?
    private var dateYmd: String?
    private var markers = [GMSMarker]()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMapView()

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

    private func setupMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        let mapView = GMSMapView.map(withFrame: self.mapContainerView.bounds, camera: camera)
        mapView.translatesAutoresizingMaskIntoConstraints = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.mapContainerView.addSubview(mapView)
        self.mapView = mapView
    }

    private func createMarker(_ rowData: LocationListDataSource.ViewRecord, into mapView: GMSMapView) -> GMSMarker {
        // Creates a marker in the center of the map.
        let marker = GMSMarker()
        let iconView = UIView(frame: CGRect(x: 0, y: 0, width: 20.0, height: 20.0))
        iconView.layer.cornerRadius = 10.0
        iconView.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        marker.iconView = iconView
        marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        let position = CLLocationCoordinate2D(latitude: rowData.latitude,
                                              longitude: rowData.longitude)
        marker.position = position
        marker.title = self.dataSource?.mainText(rowData)
        marker.snippet = self.dataSource?.subText(rowData)
        marker.map = mapView

        return marker
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
    func deleteLocations(_ indexes: [Int]) {
        guard !indexes.isEmpty else {
            return
        }
        guard isViewLoaded else {
            log.info("view unloaded.")
            return
        }
        log.info()

        indexes.forEach { (deletionIndex) in
            assert(0 <= deletionIndex && deletionIndex < self.markers.count, "配列内を指しているはず")
            if 0 <= deletionIndex && deletionIndex < self.markers.count {
                self.markers[deletionIndex].map = nil
            }
        }

        assert(indexes == indexes.sorted(), "昇順でソートされているはずß")
        // インデックスがズレないように末尾から削除していく
        indexes.sorted().reversed().forEach { (deletionIndex) in
            self.markers.remove(at: deletionIndex)
        }
    }

    func insertLocations(_ indexes: [Int]) {
        guard !indexes.isEmpty else {
            return
        }
        guard isViewLoaded else {
            log.info("view unloaded.")
            return
        }
        guard let dataSource = self.dataSource else {
            return
        }
        log.info()

        assert(indexes == indexes.sorted(), "昇順でソートされているはずß")
        indexes.sorted().forEach { (insertionIndex) in
            let rowData = dataSource.rowData(at: IndexPath(row: insertionIndex, section: 0))
            let marker = createMarker(rowData, into: self.mapView)
            self.markers.insert(marker, at: insertionIndex)
        }
    }

    func reloadLocations(_ indexes: [Int]) {
        guard !indexes.isEmpty else {
            return
        }
        guard isViewLoaded else {
            log.info("view unloaded.")
            return
        }
        log.info()
    }

    func reloadLocations() {
        guard isViewLoaded else {
            log.info("view unloaded.")
            return
        }
        guard let dataSource = self.dataSource else {
            return
        }
        log.info()
        self.markers = (0..<dataSource.numberOfRows(inSection: 0)).map { (row) -> GMSMarker in
            let indexPath = IndexPath(row: row, section: 0)
            let rowData = dataSource.rowData(at: indexPath)
            let marker = createMarker(rowData, into: self.mapView)
            return marker
        }

        if !self.markers.isEmpty {
            let rowData = dataSource.rowData(at: IndexPath(row: 0, section: 0))
            let camera = GMSCameraPosition.camera(withLatitude: rowData.latitude,
                                                  longitude: rowData.longitude,
                                                  zoom: 6.0)
            self.mapView.camera = camera
        }

    }

    func reloadData() {
        guard isViewLoaded else {
            log.info("view unloaded.")
            return
        }
        tableView.reloadData()
    }
}
