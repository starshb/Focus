//
//  ViewController.swift
//  Focus
//
//  Created by donghyun on 2021/05/30.
//

import UIKit

extension Medal {
    init(by duration: TimeInterval) {
        if duration < 30 {
            self = .bronze
        } else if 30 <= duration && duration < 50 {
            self = .silver
        } else {
            self = .gold
        }
    }
}

extension Medal {
    var icon: UIImage{
        switch self {
        case .gold:
            return UIImage(named: "gold")!
        case .silver:
            return UIImage(named: "silver")!
        case .bronze:
            return UIImage(named: "bronze")!
        }
    }
    
    var color: UIColor {
        switch self {
        case .gold:
            return UIColor(red: 255 / 255, green: 208 / 255, blue: 81 / 255, alpha: 1)
        case .silver:
            return UIColor(red: 177 / 255, green: 161 / 255, blue: 182 / 255, alpha: 1)
        case .bronze:
            return UIColor(red: 225 / 255, green: 179 / 255, blue: 170 / 255, alpha: 1)
        }
    }
}

fileprivate extension UIView {
    func animateHighlight() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.transform = .identity
            })
        })
    }
}

extension UIView {
    func makeRound(masksToBounds: Bool = false)  {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = masksToBounds
    }
}

extension UIView {
    func addShadow(with color: UIColor) {
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = color.cgColor
        self.layer.shadowRadius = 5
    }
}

class ReadyViewController: UIViewController {
    private var currentMedal = Medal.bronze
    private let range: (from: Float, to: Float) = (from: 20, to: 60)
    
    @IBOutlet weak private var iconView: UIImageView!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var slider: UISlider!
    @IBOutlet weak private var startButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.slider.value = 0
        self.startButton.makeRound()
        self.slider.minimumValue = range.from
        self.slider.maximumValue = range.to
        self.sliderValueDidChange()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        
        if identifier == "Timer" {
            let timerViewController = segue.destination as? TimerViewController
            let duration = slider.value
            
//            timerViewController?.duration = duration * 60
            timerViewController?.duration = 20
        }
    }
    
    @IBAction func sliderValueDidChange() {
        let duration = Int(slider.value)
        let medal = Medal.init(by: TimeInterval(duration))
        
        if currentMedal != medal {
            iconView.animateHighlight()
        }
        
        slider.thumbTintColor = currentMedal.color
        timeLabel.text = "\(duration) minutes"
        iconView.image = medal.icon
        
        startButton.backgroundColor = medal.color
        startButton.addShadow(with: medal.color)
        
        currentMedal = medal
    }
    
    @IBAction func presentHistory() {
        performSegue(withIdentifier: "History", sender: nil)
    }
    
    @IBAction func start() {
        performSegue(withIdentifier: "Timer", sender: nil)
    }
}
