//
//  TymeXSlider.swift
//  TymeXUIComponent
//
//  Created by Duy Huynh on 9/4/25.
//  Copyright © 2025 TymeDigital Vietnam. All rights reserved.
//

import Foundation
import UIKit

open class TymeXSlider: UIControl {
    // MARK: - Properties
     var accessibilityID: String?
     private var minimumVal: Decimal = 0.0
     private var maximumVal: Decimal = 100.0
     public var isMaxMinValueInvalid: Bool = false
     public var afterDotsUpdate: (([CALayer]) -> Void)?
     /// The minimum slider value.
    public var minimumValue: Decimal {
         get { return minimumVal }
         set {
             // Only set if the new minimum is less than the current maximum.
             if newValue < maximumValue {
                 minimumVal = newValue
                 // Ensure the current indicatorValue is within the new bounds.
                 indicatorValue = min(max(indicatorValue, minimumVal), maximumVal)
                 setNeedsLayout()
             } else {
                 print("minimumValue must be less than maximumValue")
                 isMaxMinValueInvalid = true
             }
         }
     }

    /// The maximum slider value.
    public var maximumValue: Decimal {
         get { return maximumVal }
         set {
             // Only set if the new maximum is greater than the current minimum.
             if newValue > minimumVal {
                 maximumVal = newValue
                 // Ensure the current indicatorValue is within the new bounds.
                 indicatorValue = min(max(indicatorValue, minimumVal), maximumVal)
                 setNeedsLayout()
             } else {
                 isMaxMinValueInvalid = true
             }
         }
     }

    /// The current slider value.
    open var indicatorValue: Decimal = 0 {
            didSet {
                let lower: Decimal = (valueType == .integer ? minimumVal.rounded() : minimumVal)
                let upper: Decimal = (valueType == .integer ? maximumVal.rounded() : maximumVal)
                indicatorValue = min(max(indicatorValue, lower), upper)

                updateThumbPosition(in: trackContainer.bounds)
                updateFillLayer(in: trackContainer.bounds)
                updateIndicator()

                if indicatorValue == lower || indicatorValue == upper {
                    TymeXHapticFeedback.rigid.vibrate()
                } else {
                    TymeXHapticFeedback.selection.vibrate()
                }
                sendActions(for: .valueChanged)
                setNeedsLayout()
            }
        }

    /// Private storage for numberOfSteps.
    private var numOfSteps: Int = 0
    /// Set a discrete step count (use 0 for continuous). Maximum allowed is 9.
    open var numberOfSteps: Int {
        get { return numOfSteps }
        set {
            numOfSteps = min(newValue, 9)
            setNeedsLayout()
        }
    }

    /// Control if the pop-up indicator is shown
    public var showsIndicator: Bool = true

    /// Choose between integer values or decimals (default is .decimal(places: 2)).
    public var valueType: TymeXSliderValueType = .decimal {
        didSet {
            setNeedsLayout()
        }
    }

    /// Custom rounding function.
    public var valueRounding: ((Decimal) -> Decimal)?

    /// Closure for formatting a slider value as a string.
    public var valueFormatter: ((Decimal) -> String)?

    /// Vertical offset for the indicator badge.
    public var indicatorVerticalOffset: CGFloat = SmokingCessation.spacing2

    // MARK: - Views & Layers
    /// the track container
    let trackContainer = UIView()
    /// The track layer (background).
    let trackLayer = CALayer()
    /// The fill layer (active progress).
    let fillLayer = CALayer()
    /// stack view containing labels
    lazy var labelsStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [minLabel, maxLabel])
        stackView.axis = .horizontal
        stackView.distribution = .equalSpacing
        stackView.alignment = .firstBaseline
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    /// component's main stack
    lazy var mainStack: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [trackContainer, labelsStack])
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 0
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    /// Min and max value labels.
    let minLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .right
        label.clipsToBounds = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    let maxLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textAlignment = .right
        label.clipsToBounds = true
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()

    /// The thumb image view.
    public var thumbImageView: UIImageView = {
            let img = UIImage.mxMakeThumbImage()
            let imageView = UIImageView(image: img)
            imageView.isUserInteractionEnabled = false
            return imageView
    }()

    /// The indicator label (badge) that appears when dragging.
    lazy var indicatorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.backgroundColor = .clear
        label.isHidden = true
        // 0 scale from the start
        label.transform = CGAffineTransform(scaleX: 0, y: 0)
        return label
    }()

    var indicatorDots: [CALayer] = []

    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    /// Shared initialization.
    private func commonInit() {
        // remove track layer and fill layer from super layer from the start
        trackLayer.removeFromSuperlayer()
        fillLayer.removeFromSuperlayer()
        // ading layers into track container
        trackLayer.backgroundColor = SmokingCessation.colorBackgroundInfoBase.cgColor
        trackContainer.layer.addSublayer(trackLayer)
        fillLayer.backgroundColor = SmokingCessation.colorBackgroundPrimaryBase.cgColor
        trackContainer.layer.addSublayer(fillLayer)
        trackContainer.addSubview(thumbImageView)
        trackContainer.insertSubview(indicatorLabel, belowSubview: thumbImageView)
        setupMainStack()
    }
    // MARK: - Constants
    struct ConstantsSlider {
        static let trackHeight: CGFloat = 16
    }
}

extension Decimal {
    /// Round to `scale` fractional places (0 → integer), using `.plain` (half-up)
    func rounded(scale: Int = 0,
                 mode: NSDecimalNumber.RoundingMode = .plain) -> Decimal {
        var result = Decimal()
        var source = self
        NSDecimalRound(&result, &source, scale, mode)
        return result
    }
}
