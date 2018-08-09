import UIKit

open class ToastView: UIView {
    public class Position: NSObject {
        var topOffsetPortrait: CGFloat = 0
        var topOffsetLandscape: CGFloat = 0
        var bottomOffsetPortrait: CGFloat = 0
        var bottomOffsetLandscape: CGFloat = 0

        enum PositionType: Int {
            case top
            case bottom
        }
        
        var type: PositionType
        
        public init(topOffsetPortrait: CGFloat, topOffsetLandscape: CGFloat) {
            self.topOffsetPortrait = topOffsetPortrait
            self.topOffsetLandscape = topOffsetLandscape
            type = .top
        }
        
        public init(bottomOffsetPortrait: CGFloat, bottomOffsetLandscape: CGFloat) {
            self.bottomOffsetPortrait = bottomOffsetPortrait
            self.bottomOffsetLandscape = bottomOffsetLandscape
            type = .bottom
        }
    }
    
    @objc dynamic open var position: Position = {
        let offsetPortrait: CGFloat
        let offsetLandscape: CGFloat
        switch UIDevice.current.userInterfaceIdiom {
        case .unspecified:
            offsetPortrait = 30
            offsetLandscape = 20
        case .phone:
            offsetPortrait = 30
            offsetLandscape = 20
        case .pad:
            offsetPortrait = 60
            offsetLandscape = 40
        case .tv:
            offsetPortrait = 90
            offsetLandscape = 60
        case .carPlay:
            offsetPortrait = 30
            offsetLandscape = 20
        }
        return .init(bottomOffsetPortrait: offsetPortrait, bottomOffsetLandscape: offsetLandscape)
    }()
    
  // MARK: Properties

  open var text: String? {
    get { return self.textLabel.text }
    set { self.textLabel.text = newValue }
  }


  // MARK: Appearance

  /// The background view's color.
  override open dynamic var backgroundColor: UIColor? {
    get { return self.backgroundView.backgroundColor }
    set { self.backgroundView.backgroundColor = newValue }
  }

  /// The background view's corner radius.
  @objc open dynamic var cornerRadius: CGFloat {
    get { return self.backgroundView.layer.cornerRadius }
    set { self.backgroundView.layer.cornerRadius = newValue }
  }

  /// The inset of the text label.
  @objc open dynamic var textInsets = UIEdgeInsets(top: 6, left: 10, bottom: 6, right: 10)

  /// The color of the text label's text.
  @objc open dynamic var textColor: UIColor? {
    get { return self.textLabel.textColor }
    set { self.textLabel.textColor = newValue }
  }

  /// The font of the text label.
  @objc open dynamic var font: UIFont? {
    get { return self.textLabel.font }
    set { self.textLabel.font = newValue }
  }

  /// The bottom offset from the screen's bottom in portrait mode.
  @objc open dynamic var bottomOffsetPortrait: CGFloat {
    get {
        return position.bottomOffsetPortrait
    }
    set {
        position.bottomOffsetPortrait = newValue
        position.type = .bottom
    }
  }

  /// The bottom offset from the screen's bottom in landscape mode.
  @objc open dynamic var bottomOffsetLandscape: CGFloat {
    get {
        return position.bottomOffsetLandscape
    }
    set {
        position.bottomOffsetLandscape = newValue
        position.type = .bottom
    }
  }

  // MARK: UI

  private let backgroundView: UIView = {
    let `self` = UIView()
    self.backgroundColor = UIColor(white: 0, alpha: 0.7)
    self.layer.cornerRadius = 5
    self.clipsToBounds = true
    return self
  }()
  private let textLabel: UILabel = {
    let `self` = UILabel()
    self.textColor = .white
    self.backgroundColor = .clear
    self.font = {
      switch UIDevice.current.userInterfaceIdiom {
      case .unspecified: return .systemFont(ofSize: 12)
      case .phone: return .systemFont(ofSize: 12)
      case .pad: return .systemFont(ofSize: 16)
      case .tv: return .systemFont(ofSize: 20)
      case .carPlay: return .systemFont(ofSize: 12)
      }
    }()
    self.numberOfLines = 0
    self.textAlignment = .left
    return self
  }()


  // MARK: Initializing

  public init() {
    super.init(frame: .zero)
    self.isUserInteractionEnabled = false
    self.addSubview(self.backgroundView)
    self.addSubview(self.textLabel)
  }

  required convenience public init?(coder aDecoder: NSCoder) {
    self.init()
  }


  // MARK: Layout

  override open func layoutSubviews() {
    super.layoutSubviews()
    let containerSize = ToastWindow.shared.frame.size
    let constraintSize = CGSize(
      width: containerSize.width * (280.0 / 320.0),
      height: CGFloat.greatestFiniteMagnitude
    )
    let textLabelSize = self.textLabel.sizeThatFits(constraintSize)
    self.textLabel.frame = CGRect(
      x: self.textInsets.left,
      y: self.textInsets.top,
      width: textLabelSize.width,
      height: textLabelSize.height
    )
    self.backgroundView.frame = CGRect(
      x: 0,
      y: 0,
      width: self.textLabel.frame.size.width + self.textInsets.left + self.textInsets.right,
      height: self.textLabel.frame.size.height + self.textInsets.top + self.textInsets.bottom
    )

    var x: CGFloat
    var y: CGFloat
    var width: CGFloat
    var height: CGFloat

    let orientation = UIApplication.shared.statusBarOrientation
    if orientation.isPortrait || !ToastWindow.shared.shouldRotateManually {
      width = containerSize.width
      height = containerSize.height
      y = self.bottomOffsetPortrait
    } else {
      width = containerSize.height
      height = containerSize.width
      y = self.bottomOffsetLandscape
    }

    let backgroundViewSize = self.backgroundView.frame.size
    x = (width - backgroundViewSize.width) * 0.5
    y = height - (backgroundViewSize.height + y)
    
    if position.type == .top {
        if orientation.isPortrait || !ToastWindow.shared.shouldRotateManually {
            y = position.topOffsetPortrait
        } else {
            y = position.topOffsetLandscape
        }
    }
    
    self.frame = CGRect(
      x: x,
      y: y,
      width: backgroundViewSize.width,
      height: backgroundViewSize.height
    )
  }

  override open func hitTest(_ point: CGPoint, with event: UIEvent!) -> UIView? {
    if let superview = self.superview {
      let pointInWindow = self.convert(point, to: superview)
      let contains = self.frame.contains(pointInWindow)
      if contains && self.isUserInteractionEnabled {
        return self
      }
    }
    return nil
  }

}
