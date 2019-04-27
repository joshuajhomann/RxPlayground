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
    override func viewDidLoad() {
        super.viewDidLoad()

        let startDate = Date()
        let timer = Observable
            .create { observer in
                printTread("Created Timer")
                let timer = DispatchTimer(timeInterval: 1) {
                    printTread("tick")
                    let elpased = -Int(startDate.timeIntervalSinceNow.rounded())
                    if elpased < 5 {
                        observer.onNext(elpased)
                    } else {
                        observer.onError(TimerError.expired)
                    }
                }
                return Disposables.create {
                    timer.invalidate()
                    printTread("Destroyed Timer")
                }
            }
            .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .background))
            .startWith(0)
            .map { "\($0) seconds" }
            .asDriver(onErrorJustReturn: "Expired")

        timer
            .drive(label.rx.text)
            .disposed(by: bag)

        timer
            .map { $0 == "Expired" ? UIColor.red : .black }
            .drive(label.rx.textColor)
            .disposed(by: bag)
    }

    deinit {
        print("Deinitializing ViewController")
    }


}

extension Reactive where Base: UILabel {

    /// Bindable sink for `textColor` property.
    public var textColor: Binder<UIColor> {
        return Binder(self.base) { label, color in
            label.textColor = color
        }
    }

}
