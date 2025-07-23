//
//  UIViewExt.swift
//  SmokingCessationApp
//
//  Created by Duy Huynh on 16/6/25.
//

import UIKit
import RxSwift

enum TymeXViewBorder: String {
    case leading, trailing, top, bottom
}

final class TymeXRadiusBaseLayer: CAShapeLayer {
    private lazy var disposeBag = DisposeBag()
    weak var parentView: UIView?

    override init() {
        super.init()
    }

    func observeParentViewBoundsChange() {
        parentView?.rx.observe(CGRect.self, #keyPath(UIView.bounds))
            .subscribe(onNext: { [weak self] _ in
                guard let self = self, let parentView = self.parentView else { return }
                let radius = parentView.bounds.height * 0.5
                let path = UIBezierPath(
                    roundedRect: parentView.bounds,
                    byRoundingCorners: UIRectCorner.allCorners,
                    cornerRadii: CGSize(width: radius, height: radius)
                )
                self.path = path.cgPath
            })
            .disposed(by: disposeBag)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension UIView {
    @IBInspectable public var mxCornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            if newValue == bounds.width / 2 {
                let newLayer = TymeXRadiusBaseLayer()
                newLayer.parentView = self
                newLayer.observeParentViewBoundsChange()
                layer.mask = newLayer
            } else {
                layer.cornerRadius = newValue
            }
            layer.masksToBounds = newValue > 0
        }
    }

    public func getCornerRadiusBase(forHeight height: CGFloat? = nil) -> CGFloat {
        let referenceHeight = height ?? bounds.height
        return min(referenceHeight / 2, SmokingCessation.cornerRadiusBase)
    }

    @IBInspectable public var mxBorderWidth: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }

    @IBInspectable public var mxBorderColor: UIColor? {
        get {
            return UIColor(cgColor: layer.borderColor!)
        }
        set {
            layer.borderColor = newValue?.cgColor
        }
    }
}

extension UIView {
    public func mxAddGradientBackground(
        colors: [CGColor],
        locations: [NSNumber]?,
        startPoint: CGPoint? = nil,
        endPoint: CGPoint? = nil,
        name: String? = nil) -> CAGradientLayer {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors
            gradientLayer.locations = locations
            if let startPoint = startPoint, let endPoint = endPoint {
                gradientLayer.startPoint = startPoint
                gradientLayer.endPoint = endPoint
            }
            gradientLayer.transform = CATransform3DMakeAffineTransform(
                CGAffineTransform(
                    a: 0,
                    b: 1,
                    c: -1,
                    d: 0,
                    tx: 1,
                    ty: 0
                )
            )
            gradientLayer.bounds = bounds.insetBy(
                dx: -0.5*bounds.size.width,
                dy: -0.5*bounds.size.height
            )
            gradientLayer.position = center
            gradientLayer.zPosition = -1
            self.layer.addSublayer(gradientLayer)
            return gradientLayer
        }

    public func mxRemoveGradientBackground(name: String) {
        self.layer.sublayers?.removeAll(where: { $0.name == name })
    }

    func mxRemoveGradientBoder() {
        mxRemoveGradientBackground(name: "gradientBoder")
    }

    func mxAddBackgroundForLoading(area: CGRect, color: UIColor, alpha: Float = 0.5) {
        let backgroundView = UIView(frame: area)
        backgroundView.backgroundColor = color
        backgroundView.alpha = CGFloat(alpha)
        let container = UIView(frame: area)
        container.addSubview(backgroundView)
        self.insertSubview(container, at: 1)
    }

}

extension UIView {

    public func mxFillSuperview() {
        guard let superView = superview else {
            return
        }
        mxAnchor(
            top: superView.topAnchor,
            leading: superView.leadingAnchor,
            bottom: superView.bottomAnchor,
            trailing: superView.trailingAnchor
        )
    }

    func mxAnchorSize(to view: UIView) {
        widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        heightAnchor.constraint(equalTo: view.heightAnchor).isActive = true
    }

    public func mxAnchorCenter(xAxis: NSLayoutXAxisAnchor? = nil, yAxis: NSLayoutYAxisAnchor? = nil) {
        if let cenX = xAxis {
            centerXAnchor.constraint(equalTo: cenX, constant: 0).isActive = true
        }
        if let cenY = yAxis {
            centerYAnchor.constraint(equalTo: cenY, constant: 0).isActive = true
        }
    }

    public func mxAnchor(
        top: NSLayoutYAxisAnchor? = nil,
        leading: NSLayoutXAxisAnchor? = nil,
        bottom: NSLayoutYAxisAnchor? = nil,
        trailing: NSLayoutXAxisAnchor? = nil,
        padding: UIEdgeInsets = .zero, size: CGSize = .zero
    ) {
        translatesAutoresizingMaskIntoConstraints = false

        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top).isActive = true
        }

        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }

        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom).isActive = true
        }

        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }

        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }

        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }

    public func mxAsImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in: UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}

extension UIView {
    public func mxShake(
        count: Float = 3,
        for duration: TimeInterval = 0.25,
        withTranslation translation: Float = 10
    ) {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: .linear)

        animation.repeatCount = count
        animation.duration = duration / TimeInterval(animation.repeatCount)
        animation.autoreverses = true
        animation.byValue = translation
        layer.add(animation, forKey: "shake")
    }
}

extension UIView {

    public func mxAddCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius,
                                                    height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    public func mxAddTopCorners(radius: CGFloat) {
        self.mxCornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    public func mxAddBottomCorners(radius: CGFloat) {
        self.mxCornerRadius = radius
        self.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    }

    public func mxCircledCorners() {
        mxCornerRadius = frame.height / 2
    }

    public func mxRemoveAllSubviews() {
        guard !subviews.isEmpty else { return }
        subviews.forEach { $0.removeFromSuperview() }
    }
}

extension UIView {
    func mxAnimateMoveIn(delay: Double? = 0,
                         duration: Double,
                         timingFunction: CAMediaTimingFunction,
                         distance: CGFloat? = nil,
                         completion: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(duration)
        CATransaction.setAnimationTimingFunction(timingFunction)
        var yPostion = self.frame.height
        if let distance = distance {
            yPostion = distance
        }
        let fromPos = CGPoint(x: self.frame.origin.x,
                              y: self.frame.origin.y + yPostion)
        let currentPos = self.frame.origin
        self.frame.origin = fromPos
        self.alpha = 0
        UIView.animate(withDuration: duration, delay: delay ?? 0, animations: {
            self.frame.origin = currentPos
            self.alpha = 1
        }, completion: { _ in
            self.alpha = 1
            if let completion = completion {
                completion()
            }
        })
        CATransaction.commit()
    }
}

/// Removes the height constraint of the view if it exists.
extension UIView {
    func removeHeightConstraint() {
        // Iterate through the constraints of the view
        for constraint in constraints where constraint.firstAttribute == .height {
            // Remove the height constraint
            removeConstraint(constraint)
            // Exit the loop after removing the first height constraint found
            break
        }
    }

    func removeWidthConstraint() {
        // Iterate through the constraints of the view
        for constraint in constraints where constraint.firstAttribute == .width {
            // Remove the width constraint
            removeConstraint(constraint)
            // Exit the loop after removing the first width constraint found
            break
        }
    }

    func removeWidthHeightContraints() {
        removeWidthConstraint()
        removeHeightConstraint()
    }
}

public extension UIView {
    func dequeueError<T>(withIdentifier reuseIdentifier: String, type _: T) -> String {
        return "Couldn't dequeue \(T.self) with identifier \(reuseIdentifier)"
    }

    func makeCustomRoundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask
    }

    func makeRoundCorner(size: CGFloat) {
        self.layer.cornerRadius = size
        self.layer.masksToBounds = true
    }

    func makeCircleRadius() {
        self.makeRoundCorner(size: self.frame.size.height / 2)
    }

    func makeBorder(_ color: UIColor = UIColor.clear, width: CGFloat = 1) {
        self.layer.borderColor = color.cgColor
        self.layer.borderWidth = width
    }

    func removeBorder() {
        self.layer.borderColor = UIColor.clear.cgColor
        self.layer.borderWidth = 0
    }
}

public extension UIView {
    func fixInView(_ container: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        frame = container.frame
        container.addSubview(self)
        NSLayoutConstraint(
            item: self, attribute: .leading, relatedBy: .equal,
            toItem: container, attribute: .leading, multiplier: 1.0, constant: 0
        ).isActive = true
        NSLayoutConstraint(
            item: self, attribute: .trailing, relatedBy: .equal,
            toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0
        ).isActive = true
        NSLayoutConstraint(
            item: self, attribute: .top, relatedBy: .equal,
            toItem: container, attribute: .top, multiplier: 1.0, constant: 0
        ).isActive = true
        NSLayoutConstraint(
            item: self, attribute: .bottom, relatedBy: .equal,
            toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0
        ).isActive = true
    }

    func getGradientLayer(
        colors: [UIColor] = [.blue, .white],
        locations: [NSNumber] = [0, 2],
        rect: CGRect = CGRect(x: 0, y: 0, width: 100, height: 100),
        startPoint: CGPoint = CGPoint(x: 0.0, y: 1.0),
        endPoint: CGPoint = CGPoint(x: 1.0, y: 1.0),
        type: CAGradientLayerType = .axial
    ) -> CALayer {

        let gradient = CAGradientLayer()
        gradient.frame = rect
        gradient.frame.origin = CGPoint(x: 0.0, y: 0.0)

        gradient.colors = colors.map { $0.cgColor }

        gradient.locations = locations
        gradient.startPoint = startPoint
        gradient.endPoint = endPoint
        return gradient
    }
}

