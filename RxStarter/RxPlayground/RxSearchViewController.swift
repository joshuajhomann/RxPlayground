//
//  StackOverFlowViewController.swift
//  RxPlayground
//
//  Created by Joshua Homann on 4/20/19.
//  Copyright © 2019 com.josh. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum APIError: Error {
    case invalidURL
}

class RxSearchViewController: UIViewController {
    @IBOutlet private var tableView: UITableView!
    @IBOutlet private var searchBar: UISearchBar!
    @IBOutlet private var segmentedControl: UISegmentedControl!
    private var cellText: [String] = []
    private let disposeBag = DisposeBag()
    private enum Constant {
        static let peopleURL = URL(string: "https://swapi.co/api/people/")!
        static let planetURL = URL(string: "https://swapi.co/api/planets/")!
    }
    private enum SearchType: CaseIterable {
        case character, planet
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: String(describing: UITableViewCell.self))

        let term = Observable<String>.just("")

        let searchType = Observable<SearchType>.just(.character)

        let cells: Driver<[String]> = Observable
            .combineLatest(term, searchType)
            .flatMapLatest { (combined) -> Observable<[String]> in
                let (term, searchType) = combined
                guard !term.isEmpty else {
                    return .just([])
                }

                let baseUrl: URL
                switch searchType {
                case .character:
                    baseUrl = Constant.peopleURL
                case .planet:
                    baseUrl = Constant.planetURL
                }

                var components = URLComponents(url: baseUrl, resolvingAgainstBaseURL: false)
                components?.queryItems = [URLQueryItem(name: "search", value: term)]
                guard let url = components?.url else {
                    throw APIError.invalidURL
                }

                return URLSession
                    .shared
                    .rx
                    .data(request: URLRequest(url: url))
                    .map { data in
                        switch searchType {
                        case .character:
                            return try JSONDecoder()
                                .decode(PersonContainer.self, from: data )
                                .results.map {$0.name}
                        case .planet:
                            return try JSONDecoder()
                                .decode(PlanetContainer.self, from: data )
                                .results.map {$0.name}
                        }
                    }
        }.asDriver(onErrorJustReturn: [])

        cells.drive(
            tableView
                .rx
                .items(
                    cellIdentifier: String(describing: UITableViewCell.self),
                    cellType: UITableViewCell.self)
                ) {  row, element, cell in
                    cell.textLabel?.text = element
                }
                .disposed(by: disposeBag
        )
    }
}
