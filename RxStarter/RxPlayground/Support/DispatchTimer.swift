//
//  DispatchTimer.swift
//  RxPlayground
//
//  Created by Joshua Homann on 4/22/19.
//  Copyright © 2019 com.josh. All rights reserved.
//
import Foundation

final class DispatchTimer {
    private let timer: DispatchSourceTimer
    init(timeInterval: TimeInterval, eventHandler: @escaping () -> Void) {
        timer = DispatchSource.makeTimerSource(flags: [], queue: OperationQueue.current?.underlyingQueue)
        timer.schedule(deadline: .now() + timeInterval, repeating: timeInterval)
        timer.setEventHandler(handler: eventHandler)
        timer.resume()
    }

    func invalidate() {
        timer.setEventHandler {}
        timer.cancel()
    }
}

