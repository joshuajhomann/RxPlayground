//
//  ViewController.swift
//  RxPlayground
//
//  Created by Joshua Homann on 10/15/18.
//  Copyright © 2018 com.josh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum TimerError: Error {
    case expired
}

func printTread(_ message: String) {
    print("\(message) on: \(Thread.isMainThread ? "Main thread" : "Background")")
}

class RxTimerViewController: UIViewController {
    @IBOutlet private var label: UILabel!
    private let text = BehaviorRelay<String>(value: "")
    private var date: Date?
    private let bag = DisposeBag()
    private var timer: DispatchTimer?
    override func viewDidLoad() {
        super.viewDidLoad()

        let startDate = Date()
        printTread("Created Timer")
        timer = DispatchTimer(timeInterval: 1) { [label] in
            printTread("tick")
            let elpased = -Int(startDate.timeIntervalSinceNow.rounded())
            if elpased < 5 {
                label?.text = String.init(describing: elpased)
            } else {
                label?.text = "Expired"
            }
        }

    }

    deinit {
        printTread("Destroyed Timer")
        timer?.invalidate()
        print("Deinitializing ViewController")
    }


}
