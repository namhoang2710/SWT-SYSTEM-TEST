import UIKit
import SnapKit
import Kingfisher

final class BlogListCell: UITableViewCell {
    // MARK: ‑ UI
    private let avatarView = UIImageView()
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let titleLabel = UILabel()
    private let contentLabel = UILabel()
    private let blogImageView = UIImageView()
    private let likeStack = UIStackView()
    private let heartImage = UIImageView(image: SmokingCessation().iconHeart)
    private let likeLabel = UILabel()

    private let topStack = UIStackView()

    var likeTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        selectionStyle = .none

        avatarView.layer.cornerRadius = 20
        avatarView.clipsToBounds = true
        avatarView.contentMode = .scaleAspectFill
        avatarView.backgroundColor = .systemGray5
        avatarView.snp.makeConstraints { $0.size.equalTo(CGSize(width: 40, height: 40)) }

        nameLabel.font = .preferredFont(forTextStyle: .subheadline)
        metaLabel.font = .preferredFont(forTextStyle: .caption2)
        metaLabel.textColor = .secondaryLabel

        let nameStack = UIStackView(arrangedSubviews: [nameLabel, metaLabel])
        nameStack.axis = .vertical
        nameStack.spacing = 2

        topStack.axis = .horizontal
        topStack.spacing = 8
        topStack.alignment = .center
        topStack.addArrangedSubview(avatarView)
        topStack.addArrangedSubview(nameStack)

        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.numberOfLines = 0
        contentLabel.font = .preferredFont(forTextStyle: .body)
        contentLabel.numberOfLines = 4
        contentLabel.textColor = .label

        blogImageView.contentMode = .scaleAspectFill
        blogImageView.clipsToBounds = true
        blogImageView.layer.cornerRadius = 8

        likeStack.axis = .horizontal
        likeStack.spacing = 4
        likeStack.alignment = .center
        heartImage.tintColor = .tertiaryLabel
        heartImage.snp.makeConstraints { $0.size.equalTo(16) }
        likeLabel.font = .preferredFont(forTextStyle: .caption2)
        likeStack.addArrangedSubview(heartImage)
        likeStack.addArrangedSubview(likeLabel)

        likeStack.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapLike))
        likeStack.addGestureRecognizer(tap)

        let vStack = UIStackView(arrangedSubviews: [topStack, titleLabel, contentLabel, blogImageView, likeStack])
        vStack.axis = .vertical
        vStack.spacing = 8
        contentView.addSubview(vStack)
        vStack.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(12)
        }
        blogImageView.snp.makeConstraints { $0.height.equalTo(180) }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        avatarView.image = nil
        blogImageView.image = nil
    }

    func configure(with blog: Blog) {
        nameLabel.text = blog.account.name
        metaLabel.text = "\(blog.createdDate) lúc \(blog.createdTime)"
        titleLabel.text = blog.title
        contentLabel.text = blog.content

        if let urlStr = blog.account.image, let url = URL(string: urlStr) {
            avatarView.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle"))
        }
        if let img = blog.image, !img.isEmpty, let url = URL(string: img.hasPrefix("http") ? img : BaseAPI.baseURL.absoluteString + img) {
            blogImageView.kf.setImage(with: url, placeholder: UIImage(systemName: "photo"))
            blogImageView.isHidden = false
        } else {
            blogImageView.isHidden = true
        }

        likeLabel.text = String(blog.likes)
//        heartImage.tintColor = blog == true ? .systemRed : .tertiaryLabel
    }

    @objc private func didTapLike() { likeTapped?() }
} 
