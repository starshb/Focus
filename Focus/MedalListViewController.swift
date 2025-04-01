//
//  HistoryViewController.swift
//  Focus
//
//  Created by donghyun on 2021/06/06.
//

import Foundation
import UIKit

extension Date {
    func formatted() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy. MM. dd. HH:mm"
        return formatter.string(from: self)
    }
}

class MedalCell: UITableViewCell {
    @IBOutlet weak private var iconView: UIImageView!
    @IBOutlet weak private var dateLabel: UILabel!
    @IBOutlet weak private var timeLabel: UILabel!
    
    func update(duration: TimeInterval, date: Date) {
        let medal = Medal.init(by: duration)
        
        iconView.image = medal.icon
        dateLabel.text = date.formatted()
        timeLabel.text = "\(duration) minutes"
    }
}

class MedalListViewController: UIViewController {
    lazy private var list: [[String: Any]] = {
        let defaults = UserDefaults.standard
        let list = defaults.object(forKey: "list") as? [[String: Any]] ?? []
        
        return list.sorted(by: { left, right in
            let lhs = left["date"] as! Date
            let rhs = right["date"] as! Date
            
            return lhs > rhs
        })
    }()
    
    @IBOutlet weak private var tableView: UITableView!
    
    @IBAction func close() {
        self.dismiss(animated: true, completion: nil)
    }
}

extension MedalListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MedalCell", for: indexPath) as! MedalCell
        
        let duration = list[indexPath.row]["duration"] as! TimeInterval
        let date = list[indexPath.row]["date"] as! Date
        
        cell.update(duration: duration, date: date)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        80
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        list.count
    }
}
