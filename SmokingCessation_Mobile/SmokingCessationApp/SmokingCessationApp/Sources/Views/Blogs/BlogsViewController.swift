////
////  BlogsViewController.swift
////  SmokingCessationApp
////
////  Created by Duy Huynh on 27/6/25.
////
//
//import Foundation
//import UIKit
//import RxSwift
//import UIKit
//import RxSwift
//import SnapKit
//
//final class BlogListViewController: UIViewController, TymeXLoadingViewable {
//
//    private let table = UITableView()
//    private let refresh = UIRefreshControl()
//    private let vm = BlogListViewModel(service: DIContainer.shared.resolve(BlogServiceProtocol.self)!)
//    private let bag = DisposeBag()
//    weak var coordinator: BlogsCoordinator?
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        title = "Blogs"
//        view.backgroundColor = .systemBackground
//        setupTable()
//        bind()
//        vm.loadTrigger.accept(())
//    }
//
//    private func setupTable() {
//        table.register(BlogListCell.self, forCellReuseIdentifier: "BlogCell")
//        table.rowHeight = UITableView.automaticDimension
//        table.estimatedRowHeight = 200
//        table.refreshControl = refresh
//        view.addSubview(table)
//        table.snp.makeConstraints { $0.edges.equalTo(view) }
//        table.dataSource = self
//
//        refresh.addTarget(self, action: #selector(pulled), for: .valueChanged)
//    }
//
//    private func bind() {
//        vm.blogs
//            .observe(on: MainScheduler.instance)
//            .subscribe { [weak self] _ in
//                self?.table.reloadData()
//            }
//            .disposed(by: bag)
//
//        vm.isLoading
//            .skip(1)
//            .observe(on: MainScheduler.instance)
//            .subscribe { [weak self] loading in
//                if loading {
//                    self?.mxShowFullScreenLoadingView(duration: 0,
//                                         lottieAnimationName: SmokingCessation.loadingAnimation,
//                                         bundle: BundleSmokingCessation.bundle)
//                } else {
//                    self?.tymeXHideLoadingView()
//                    self?.refresh.endRefreshing()
//                }
//            }
//            .disposed(by: bag)
//
//        vm.error
//            .observe(on: MainScheduler.instance)
//            .subscribe { [weak self] msg in
//                self?.showToastMessage(message: msg, icon: .icError.withTintColor(.red), direction: .top)
//            }
//            .disposed(by: bag)
//    }
//
//    @objc private func pulled() { vm.loadTrigger.accept(()) }
//}
//
//extension BlogListViewController: UITableViewDataSource {
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        vm.blogs.value.count
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        let cell = table.dequeueReusableCell(withIdentifier: "BlogCell", for: indexPath) as! BlogListCell
//        cell.configure(with: vm.blogs.value[indexPath.row])
//        return cell
//    }
//}
