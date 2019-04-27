//
//  RxSpirographViewController.swift
//  RxPlayground
//
//  Created by Joshua Homann on 4/22/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa


class RxSpirographViewController: UIViewController {
    
    @IBOutlet private var imageView: UIImageView!
    @IBOutlet private var majorSlider: UISlider!
    @IBOutlet private var minorSlider: UISlider!
    @IBOutlet private var offsetSlider: UISlider!
    @IBOutlet private var sampleSlider: UISlider!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    @IBOutlet private var majorLabel: UILabel!
    @IBOutlet private var minorLabel: UILabel!
    @IBOutlet private var offsetLabel: UILabel!
    @IBOutlet private var samplesLabel: UILabel!
    private let bag = DisposeBag()
    private lazy var imageRenderer: UIGraphicsImageRenderer = {
        let minimumDimenision = min(UIScreen.main.bounds.size.width, UIScreen.main.bounds.size.height) - 24
        return UIGraphicsImageRenderer(bounds: CGRect(
            origin: .zero,
            size: .init(width: minimumDimenision, height: minimumDimenision)
        ))
    }()
    private let colors: [UIColor] = [#colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1),#colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1),#colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1),#colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)]

    override func viewDidLoad() {
        super.viewDidLoad()

        let numberFormatter = with(NumberFormatter()) {
            $0.minimumFractionDigits = 1
            $0.minimumIntegerDigits = 1
        }

        majorSlider.rx.value.asDriver()
            .map { numberFormatter.string(for: $0)}
            .drive(majorLabel.rx.text)
            .disposed(by: bag)
        minorSlider.rx.value.asDriver()
            .map { numberFormatter.string(for: $0)}
            .drive(minorLabel.rx.text)
            .disposed(by: bag)
        offsetSlider.rx.value.asDriver()
            .map { numberFormatter.string(for: $0)}
            .drive(offsetLabel.rx.text)
            .disposed(by: bag)
        sampleSlider.rx.value.asDriver()
            .map { numberFormatter.string(for: $0)}
            .drive(samplesLabel.rx.text)
            .disposed(by: bag)

        let inputDriver = Driver.combineLatest(
            majorSlider.rx.value.asDriver(),
            minorSlider.rx.value.asDriver(),
            offsetSlider.rx.value.asDriver(),
            sampleSlider.rx.value.asDriver(),
            segmentedControl.rx.value.asDriver()
        ).distinctUntilChanged { left, right in
            left.0 == right.0 &&
            left.1 == right.1 &&
            left.2 == right.2 &&
            left.3 == right.3 &&
            left.4 == right.4
        }

        let imageDriver = inputDriver
            .flatMapLatest { [imageRenderer, colors] (combined) -> Driver<UIImage?> in
                let (major, minor, offset, sample, colorIndex) = combined
                return Observable.create { observer in
                    observer.onNext(
                        imageRenderer.image(
                            from: SpirographGenerator(
                                majorRadius: CGFloat(major),
                                minorRadius: CGFloat(minor),
                                pointOffset: CGFloat(offset),
                                samples: CGFloat(sample)
                            ),
                            dimension: UIScreen.main.bounds.size.width - 24,
                            color: colors[colorIndex]
                        )
                    )
                    return Disposables.create()
                }
                .subscribeOn(ConcurrentDispatchQueueScheduler(qos: .userInteractive))
                .asDriver(onErrorJustReturn: nil)
        }

        imageDriver
            .drive(imageView.rx.image)
            .disposed(by: bag)
    }
}
