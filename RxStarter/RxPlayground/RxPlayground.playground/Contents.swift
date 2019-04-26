import UIKit
import RxSwift

enum MyError: Error {
    case divideByZero
}

let bag = DisposeBag()

let observable = Observable.from(0..<3)


observable.subscribe { event in
    switch event {
    case .next(let element):
        print(element)
    case .completed:
        print("completed")
    case .error(let error):
        print(error)
    }
}.disposed(by: bag)

observable.subscribe(
    onNext: { element in
        print(element)
    },
    onError: { error in
        print(error)
    },
    onCompleted: {
        print("completed")
    },
    onDisposed: {
        print("disposed")
    }
).disposed(by: bag)
