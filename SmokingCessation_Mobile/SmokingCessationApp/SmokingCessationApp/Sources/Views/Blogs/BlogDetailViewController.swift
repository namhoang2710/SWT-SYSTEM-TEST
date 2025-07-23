import UIKit
import SnapKit
import RxSwift

final class BlogDetailViewController: UIViewController, TymeXLoadingViewable {
    private let blog: Blog
    private var comments: [Comment] = []
    private let disposeBag = DisposeBag()

    // UI
    private let scrollView = UIScrollView()
    private let contentStack = UIStackView()
    private let commentsTable = UITableView()
    private let commentField = UITextField()
    private let sendButton = PrimaryButton()
    private let inputBar = UIVisualEffectView(effect: UIBlurEffect(style: .systemMaterial))
    private let refreshControl = UIRefreshControl()
    private var commentsHeight: Constraint?

    init(blog: Blog) {
        self.blog = blog
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Chi tiết Blog"
        setupUI()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchComments()
    }

    private func setupUI() {
        contentStack.axis = .vertical; contentStack.spacing = 8
        scrollView.addSubview(contentStack)
        view.addSubview(scrollView)
        view.addSubview(commentsTable)

        scrollView.snp.makeConstraints { make in
            make.top.leading.trailing.bottom.equalTo(view)
        }
        contentStack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide).inset(16)
            make.width.equalTo(view).offset(-32)
        }

        // top blog view
        let cell = BlogListCell(style: .default, reuseIdentifier: nil)
        cell.configure(with: blog)
        contentStack.addArrangedSubview(cell.contentView)

        // comments label
        let lbl = UILabel(); lbl.text = "Bình luận"; lbl.font = .preferredFont(forTextStyle: .headline)
        contentStack.addArrangedSubview(lbl)

        // comments table
        commentsTable.register(CommentCell.self, forCellReuseIdentifier: "cmtCell")
        commentsTable.dataSource = self
        commentsTable.rowHeight = UITableView.automaticDimension
        commentsTable.estimatedRowHeight = 100
        contentStack.addArrangedSubview(commentsTable)
        commentsTable.snp.makeConstraints { make in
            commentsHeight = make.height.equalTo(100).constraint
        }

        // floating input bar
        commentField.borderStyle = .roundedRect
        commentField.placeholder = "Viết bình luận..."
        sendButton.setTitle(with: .text("Gửi"))
        sendButton.setShowLoadingForTouchUpInside(false)
        let composerStack = UIStackView(arrangedSubviews: [commentField, sendButton])
        composerStack.axis = .horizontal; composerStack.spacing = 8
        inputBar.contentView.addSubview(composerStack)
        view.addSubview(inputBar)
        inputBar.snp.makeConstraints { make in
            make.leading.trailing.equalTo(view)
            make.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        composerStack.snp.makeConstraints { make in
            make.edges.equalTo(inputBar.contentView).inset(12)
        }
        commentField.snp.makeConstraints { $0.height.equalTo(36) }
        sendButton.snp.makeConstraints { $0.width.equalTo(60) }
        sendButton.addTarget(self, action: #selector(sendComment), for: .touchUpInside)

        // adjust scrollView bottom
        scrollView.snp.remakeConstraints { make in
            make.top.leading.trailing.equalTo(view)
            make.bottom.equalTo(inputBar.snp.top)
        }

        // refresh
        refreshControl.addTarget(self, action: #selector(refreshPulled), for: .valueChanged)
        scrollView.refreshControl = refreshControl
    }

    private func bind() {}

    private func fetchComments() {
        mxShowFullScreenLoadingView(duration: 0, lottieAnimationName: SmokingCessation.loadingAnimation, bundle: BundleSmokingCessation.bundle)
        DIContainer.shared.resolve(BlogServiceProtocol.self)!
            .fetchComments(blogId: blog.blogID)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] list in
                self?.comments = list
                self?.commentsTable.reloadData()
                self?.updateTableHeight()
                self?.refreshControl.endRefreshing()
                self?.tymeXHideLoadingView()
            }, onFailure: { [weak self] err in
                self?.tymeXHideLoadingView()
                self?.refreshControl.endRefreshing()
                self?.showToastMessage(message: err.localizedDescription, icon: .icError.withTintColor(.red), direction: .top)
            })
            .disposed(by: disposeBag)
    }

    private func updateTableHeight() {
        commentsTable.layoutIfNeeded()
        commentsHeight?.update(offset: commentsTable.contentSize.height)
    }

    @objc private func sendComment() {
        let text = commentField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !text.isEmpty else { return }
        commentField.text = ""
        DIContainer.shared.resolve(BlogServiceProtocol.self)!
            .createComment(blogId: blog.blogID, content: text)
            .observe(on: MainScheduler.instance)
            .subscribe(onSuccess: { [weak self] in
                self?.fetchComments()
            }, onFailure: { [weak self] err in
                self?.showToastMessage(message: err.localizedDescription, icon: .icError.withTintColor(.red), direction: .top)
            })
            .disposed(by: disposeBag)
    }

    @objc private func refreshPulled() { fetchComments() }
}

extension BlogDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { comments.count }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cmtCell", for: indexPath) as! CommentCell
        cell.configure(comments[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        updateTableHeight()
    }
} 
