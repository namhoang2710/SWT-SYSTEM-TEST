import UIKit
import SnapKit

final class PurchasedPackageCell: UITableViewCell {
    private let nameLabel = UILabel()
    private let priceLabel = UILabel()
    private let dateLabel = UILabel()
    private let container = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        selectionStyle = .none
        container.axis = .vertical
        container.spacing = 4
        container.alignment = .leading
        contentView.addSubview(container)
        container.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(16)
        }
        [nameLabel, priceLabel, dateLabel].forEach { container.addArrangedSubview($0) }
        nameLabel.font = UIFont.preferredFont(forTextStyle: .extraLargeTitle)
        priceLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        priceLabel.textColor = .systemGreen
        dateLabel.font = UIFont.preferredFont(forTextStyle: .caption1)
        dateLabel.textColor = .secondaryLabel
    }

    func configure(with pkg: PurchasedPackage) {
        nameLabel.text = pkg.name
        priceLabel.text = "Giá: \(pkg.price)₫"
        // Format date string
        var displayDate = pkg.purchaseDate
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        var parsedDate: Date? = isoFormatter.date(from: pkg.purchaseDate)
        if parsedDate == nil {
            // Fallback custom pattern e.g. "yyyy-MM-dd'T'HH:mm.SSSSSS"
            let custom = DateFormatter()
            custom.locale = Locale(identifier: "en_US_POSIX")
            custom.dateFormat = "yyyy-MM-dd'T'HH:mm.SSSSSS"
            parsedDate = custom.date(from: pkg.purchaseDate)
        }
        if let date = parsedDate {
            let df = DateFormatter()
            df.dateStyle = .medium
            df.timeStyle = .short
            displayDate = df.string(from: date)
        }
        dateLabel.text = "Ngày bạn mua: \(displayDate)"
    }
} 
 