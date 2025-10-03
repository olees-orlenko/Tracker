import UIKit

final class GradientCardView: UIView {
    
    // MARK: - Private Properties
    
    private let borderWidth: CGFloat
    private let cornerR: CGFloat
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Properties
    
    let contentView = UIView()
    
    // MARK: - Init
    
    init(borderWidth: CGFloat = 1.0, cornerRadius: CGFloat = 16.0, colors: [CGColor]) {
        self.borderWidth = borderWidth
        self.cornerR = cornerRadius
        super.init(frame: .zero)
        setup(colors: colors)
    }
    
    required init?(coder: NSCoder) {
        self.borderWidth = 1.0
        self.cornerR = 16.0
        super.init(coder: coder)
        setup(colors: [])
    }
    
    private func setup(colors: [CGColor]) {
        backgroundColor = .clear
        layer.cornerRadius = cornerR
        clipsToBounds = true
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.colors = colors.isEmpty
        ? [UIColor.systemBlue.cgColor, UIColor.systemGreen.cgColor, UIColor.systemRed.cgColor]
        : colors
        layer.addSublayer(gradientLayer)
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = max(0, cornerR - borderWidth)
        contentView.clipsToBounds = true
        addSubview(contentView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        gradientLayer.cornerRadius = cornerR
        contentView.frame = bounds.insetBy(dx: borderWidth, dy: borderWidth)
        contentView.layer.cornerRadius = max(0, cornerR - borderWidth)
    }
}
