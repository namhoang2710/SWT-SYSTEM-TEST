import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class BlogListViewController: UIViewController, TymeXLoadingViewable {
    private let disposeBag = DisposeBag()
    private let viewModel = BlogListViewModel(service: DIContainer.shared.resolve(BlogServiceProtocol.self)!)
    weak var coordinator: BlogsCoordinator?
    private let tableView = UITableView()
    private let searchBar = TymeXSearchBar()
    private let refresh = UIRefreshControl()

    private var allBlogs: [Blog] = []
    private var filtered: [Blog] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Blogs"
        view.backgroundColor = .systemBackground
        setupUI()
        bind()
        viewModel.loadTrigger.accept(())
    }

    private func setupUI() {
        searchBar.placeholder = "Tìm kiếm blog"
        searchBar.leftImage = UIImage(systemName: "magnifyingglass")
        searchBar.delegate = self
        view.addSubview(searchBar)
        view.addSubview(tableView)

        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(8)
            make.leading.trailing.equalTo(view).inset(16)
            make.height.equalTo(48)
        }
        tableView.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view)
        }
        tableView.register(BlogListCell.self, forCellReuseIdentifier: "blogCell")
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        tableView.dataSource = self
        tableView.delegate = self
        tableView.refreshControl = refresh
        refresh.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
    }

    private func bind() {
        viewModel.blogs
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] blogs in
                self?.allBlogs = blogs
                self?.applyFilter(text: self?.searchBar.text ?? "")
            })
            .disposed(by: disposeBag)

        viewModel.isLoading
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] load in
                if load {
                    self?.mxShowFullScreenLoadingView(duration: 0, lottieAnimationName: SmokingCessation.loadingAnimation, bundle: BundleSmokingCessation.bundle)
                } else {
                    self?.tymeXHideLoadingView()
                    self?.refresh.endRefreshing()
                }
            })
            .disposed(by: disposeBag)

        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] msg in
                self?.showToastMessage(message: msg, icon: .icError.withTintColor(.red), direction: .top)
            })
            .disposed(by: disposeBag)
    }

    @objc private func refreshPulled() { viewModel.loadTrigger.accept(()) }

    private func applyFilter(text: String) {
        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            filtered = allBlogs
        } else {
            let key = text.lowercased()
            filtered = allBlogs.filter {
                $0.title.lowercased().contains(key) ||
                $0.content.lowercased().contains(key) ||
                $0.account.name.lowercased().contains(key)
            }
        }
        tableView.reloadData()
    }
}

extension BlogListViewController: TymeXSearchBarDelegate {
    func searchBar(_ searchBar: TymeXSearchBar, textDidChange searchText: String) {
        applyFilter(text: searchText)
    }
}

extension BlogListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "blogCell", for: indexPath) as! BlogListCell
        let blog = filtered[indexPath.row]
        cell.configure(with: blog)
        cell.likeTapped = { [weak self] in
            guard let self = self else { return }
            self.likeBlog(blog)
        }
        return cell
    }

    private func likeBlog(_ blog: Blog) {
        DIContainer.shared.resolve(BlogServiceProtocol.self)!
            .toggleLike(blogId: blog.blogID)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] resp in
                guard let self = self else { return }
                if let idx = self.allBlogs.firstIndex(where: { $0.blogID == blog.blogID }) {
                    self.allBlogs[idx].likes = resp.likes
//                    self.allBlogs[idx].liked = resp.message == "Liked"
                }
                self.applyFilter(text: self.searchBar.text ?? "")
            }) { [weak self] err in
                self?.showToastMessage(message: err.localizedDescription, icon: .icError.withTintColor(.red), direction: .top)
            }.disposed(by: disposeBag)
    }
}

extension BlogListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let blog = filtered[indexPath.row]
        let vc = BlogDetailViewController(blog: blog)
        navigationController?.pushViewController(vc, animated: true)
    }
} 
