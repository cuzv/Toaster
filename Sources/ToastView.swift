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
        case .mac:
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
  @objc open dynamic var backgroundCornerRadius: CGFloat {
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
      case .mac:  return .systemFont(ofSize: 20)
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

    private var isPortrait: Bool {
        return UIApplication.shared.statusBarOrientation.isPortrait || !ToastWindow.shared.shouldRotateManually
    }
    
  override open func layoutSubviews() {
    super.layoutSubviews()

    let width = isPortrait ? ToastWindow.shared.frame.size.width : ToastWindow.shared.frame.size.height
    
    let textMaxWidth = ToastWindow.shared.frame.size.width - 40 - textInsets.left - textInsets.right
    let textConstraintSize = CGSize(width: textMaxWidth, height: CGFloat.greatestFiniteMagnitude)
    let textSize = textLabel.sizeThatFits(textConstraintSize)
    let textCenter = CGPoint(x: width / 2.0, y: textSize.height / 2.0 + textInsets.top)
    textLabel.bounds = CGRect(origin: .zero, size: textSize)
    textLabel.center = textCenter
    
    let backgroundSize = CGSize(width: textSize.width + textInsets.left + textInsets.right, height: textSize.height + textInsets.top + textInsets.bottom)
    backgroundView.bounds = CGRect(origin: .zero, size: backgroundSize)
    backgroundView.center = textLabel.center
    
    let y: CGFloat
    if position.type == .top {
        if isPortrait {
            y = position.topOffsetPortrait
        } else {
            y = position.topOffsetLandscape
        }
    } else {
        if isPortrait {
            y = ToastWindow.shared.frame.size.height - position.bottomOffsetPortrait - backgroundSize.height
        } else {
            y = ToastWindow.shared.frame.size.width - position.bottomOffsetLandscape - backgroundSize.height
        }
    }
    
    self.frame = CGRect(x: 0, y: y, width: width, height: backgroundSize.height)
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
