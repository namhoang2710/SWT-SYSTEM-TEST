import UIKit
import SnapKit
import Kingfisher

final class CommentCell: UITableViewCell {
    private let avatar = UIImageView()
    private let nameLabel = UILabel()
    private let metaLabel = UILabel()
    private let contentLabel = UILabel()
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setup() {
        selectionStyle = .none
        avatar.layer.cornerRadius = 16
        avatar.clipsToBounds = true
        avatar.snp.makeConstraints { $0.size.equalTo(32) }
        nameLabel.font = .preferredFont(forTextStyle: .subheadline)
        metaLabel.font = .preferredFont(forTextStyle: .caption2)
        metaLabel.textColor = .secondaryLabel
        contentLabel.font = .preferredFont(forTextStyle: .body)
        contentLabel.numberOfLines = 0

        let rightStack = UIStackView(arrangedSubviews: [nameLabel, metaLabel, contentLabel])
        rightStack.axis = .vertical; rightStack.spacing = 2

        stack.axis = .horizontal; stack.spacing = 8; stack.alignment = .top
        stack.addArrangedSubview(avatar)
        stack.addArrangedSubview(rightStack)
        contentView.addSubview(stack)
        stack.snp.makeConstraints { $0.edges.equalTo(contentView).inset(12) }
    }

    func configure(_ c: Comment) {
        nameLabel.text = c.commenterName
        metaLabel.text = "\(c.createdDate) \(c.createdTime)"
        contentLabel.text = c.content
        if let url = URL(string: c.commenterImage ?? "") {
            avatar.kf.setImage(with: url, placeholder: UIImage(systemName: "person.circle"))
        }
    }
} 