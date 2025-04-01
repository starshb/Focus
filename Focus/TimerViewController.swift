//
//  TimerViewController.swift
//  Focus
//
//  Created by donghyun on 2021/07/14.
//

import Foundation
import UIKit

enum TimerStatus {
    case active
    case background
    case lockscreen
}

class TimerViewController: UIViewController {
    typealias Second = Int
    
    var duration: Second =  0
    
    private let cheerUpMessages = [
        "화이팅해요!",
        "조금 더 집중 해볼까요?"
    ]
    
    private var lastStatus: TimerStatus = .active
    
    private var remaining: Second {
        duration - Int(Date().timeIntervalSince1970 - start.timeIntervalSince1970)
    }
    
    private var timer: Timer?
    private var start = Date()
    
    private var deactiveTime: Date?
    
    private var finished = false
    
    @IBOutlet weak private var cheerUpLabel: UILabel!
    @IBOutlet weak private var durationLabel: UILabel!
    @IBOutlet weak private var progressContainer: UIView!
    @IBOutlet weak private var progressWidth: NSLayoutConstraint!
    @IBOutlet weak private var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        
        self.cheerUpLabel.text = cheerUpMessages.randomElement()
        self.progressWidth.constant = progressContainer.frame.width
        self.progressContainer.makeRound(masksToBounds: true)
        self.cancelButton.makeRound()
        self.updateDuration(seconds: duration)
        self.addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if timer == nil {
            self.updateDuration(seconds: duration)
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        }
    }

    private func addObservers() {
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(locked), name: UIApplication.protectedDataWillBecomeUnavailableNotification, object: nil)
        center.addObserver(self, selector: #selector(enteredBackground), name:  UIScene.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(becomeActive), name: UIScene.didActivateNotification, object: nil)
        center.addObserver(self, selector: #selector(enterForeground), name: UIScene.willEnterForegroundNotification, object: nil)
    }
    
    private func updateDuration(seconds: Second) {
        let hours = max(seconds / 60, 0)
        let minutes = max(seconds % 60, 0)
        
        durationLabel.text = String(format: "%02d:%02d", hours, minutes)
        progressWidth.constant = CGFloat(remaining) / CGFloat(duration) * progressContainer.frame.width
    }
    
    private func finish(success: Bool) {
        let title = success ? "성공했어요!" : "실패했습니다 ㅠㅠ"
        let message = success ? "메달을 획득했어요!" : "집중하기에 실패했어요! 다시 시도해주세요!"
        
        let controller = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "확인", style: .default, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        
        controller.addAction(action)
            
        if self.presentedViewController != nil {
            self.dismiss(animated: false, completion: nil)
        }
        
        self.present(controller, animated: true, completion: nil)
    }
    
    private func addNotification(at date: Date, title: String, message: String) {
        let components = Calendar.current.dateComponents([.year,. month, .day, .hour, .minute, .second], from: date)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let content = UNMutableNotificationContent()
        let identifier = "\(Date().timeIntervalSince1970)"
        
        content.title = title
        content.body = message
        
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        let center = UNUserNotificationCenter.current()
        
        center.add(request, withCompletionHandler: { error in
            if let error = error {
                print(error)
            }
        })
    }
    
    @IBAction private func cancel() {
        let controller = UIAlertController(title: "취소하시겠습니까?", message: "취소하면 메달을 얻을 수 없어요!", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "계속하기", style: .cancel, handler: nil)
        
        let okAction = UIAlertAction(title: "그만하기", style: .destructive, handler: { _ in
            self.dismiss(animated: true, completion: nil)
        })
        
        controller.addAction(cancelAction)
        controller.addAction(okAction)
        
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc private func enterForeground() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        updateDuration(seconds: remaining)
    }
    
    @objc private func becomeActive() {
        var didFail = false
        let didExpired = (start.timeIntervalSince1970 + TimeInterval(duration)) < Date().timeIntervalSince1970
        
        // 백그라운드에서 진입했을때
        if lastStatus == .background {
            if didExpired {
                didFail = true
            } else if let time = deactiveTime, time.addingTimeInterval(10).timeIntervalSince1970 < Date().timeIntervalSince1970 {
                didFail = true
            } else {
                didFail = false
            }
        }
        
        if lastStatus == .lockscreen && didExpired && finished == false {
            finish(success: true)
            finished = true
            timer?.invalidate()
        }
        
        if didFail && finished == false {
            finish(success: false)
            timer?.invalidate()
            finished = true
        }
        
        lastStatus = .active
        deactiveTime = nil
    }
    
    @objc private func enteredBackground() {
        guard finished == false else {
            return
        }
        
        let now = Date()
        
        lastStatus = .background
        deactiveTime = now
        addNotification(at: now.addingTimeInterval(5), title: "얼른 다시 딥중해주세요!", message: "얼른 복귀히자 않으면 메달을 얻을 수 없어요!")
    }
    
    @objc private func locked(){
        guard finished == false else {
            return
        }
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        lastStatus = .lockscreen
        deactiveTime = Date()
        addNotification(at: start.addingTimeInterval(TimeInterval(duration)), title: "성공했어요!", message: "집중하기에 성공했어요!")
    }
    
    @objc private func tick() {
        guard lastStatus == .active else {
            return
        }
        
        if remaining > 0 && remaining % 15 == 0 {
            cheerUpLabel.text = cheerUpMessages.randomElement()
        }
        
        if remaining <= 0 {
            timer?.invalidate()
            finished = true
            save()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                
                self?.finish(success: true)
            }
        }
        
        updateDuration(seconds: remaining)
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        
        var list = defaults.object(forKey: "list") as? [[String: Any]] ?? []
        
        list.append(["duration": self.duration, "date": start])
        
        defaults.setValue(list, forKey: "list")
        defaults.synchronize()
    }
}
