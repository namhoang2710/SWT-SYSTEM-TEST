import UIKit
import SnapKit

final class SmokingLogCell: UITableViewCell {
    private let dateLabel = UILabel()
    private let cigarettesLabel = UILabel()
    private let healthLabel = UILabel()
    private let cravingLabel = UILabel()
    private let notesLabel = UILabel()
    private let stack = UIStackView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        selectionStyle = .none
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        contentView.addSubview(stack)
        stack.snp.makeConstraints { make in
            make.edges.equalTo(contentView).inset(12)
        }
        [dateLabel, cigarettesLabel, healthLabel, cravingLabel, notesLabel].forEach { lbl in
            lbl.numberOfLines = 0
            stack.addArrangedSubview(lbl)
        }
        dateLabel.font = .preferredFont(forTextStyle: .headline)
        cigarettesLabel.font = .preferredFont(forTextStyle: .subheadline)
        healthLabel.font = .preferredFont(forTextStyle: .subheadline)
        cravingLabel.font = .preferredFont(forTextStyle: .subheadline)
        notesLabel.font = .preferredFont(forTextStyle: .caption1)
        notesLabel.textColor = .secondaryLabel
    }

    func configure(with log: SmokingLog) {
        dateLabel.text = "Ngày: \(log.date)"
        cigarettesLabel.text = "Số điếu: \(log.cigarettes)  |  Chi phí: \(log.cost)₫"
        healthLabel.text = "Sức khoẻ: \(log.healthStatus)"
        cravingLabel.text = "Mức độ thèm: \(log.cravingLevel)"
        notesLabel.text = "Ghi chú: \(log.notes)"
    }
} 