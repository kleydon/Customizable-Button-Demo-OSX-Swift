//QXButton.swift


//Comprehensive subclass of NSButton supporting:
// * Rounded corners
// * Glow
// * Background color
// * Border color
// * Border thickness
// * Setting the above parameters using InterfaceBuilder

//My additions:
// * Roll-over highlighting
// * Re-scaling images (Currently limited to full-frame images, or scaling set to none)

//Inspired primarily by:
//https://github.com/OskarGroth/FlatButton
//Also looked at:
//https://github.com/Concpt13/MXButton - ObjC
//https://github.com/Sunnyyoung/SYFlatButton - ObjC. Used for a while

//Note: Be sure to specify IBOutlets as for QXButton, not NSButton


import Cocoa

class QXButton: NSButton, CALayerDelegate {
    
    
    internal var containerLayer = CALayer()
    internal var primaryIconLayer = CAShapeLayer()
    internal var alternateIconLayer = CAShapeLayer()
    internal var titleLayer = CATextLayer()
    internal var mouseDown = Bool()
    internal var mouseOver = Bool()
    internal var trackingArea = NSTrackingArea()

    
    //Apple notes: willSet and didSet observers are not called when a property is first initialized.

    @IBInspectable public var momentary: Bool = true {
        didSet {
            updateColors(state == .on)
        }
    }
    @IBInspectable public var glowRadius: CGFloat = 0 {
        didSet {
            containerLayer.shadowRadius = glowRadius
            updateColors(state == .on)
        }
    }
    @IBInspectable public var glowOpacity: Float = 0 {
        didSet {
            containerLayer.shadowOpacity = glowOpacity
            updateColors(state == .on)
        }
    }
    @IBInspectable public var hoverHighlightingEnabled: Bool = true {
        didSet {
          updateColors(state == .off)
        }
    }
    @IBInspectable public var cornerRadius: CGFloat = 4 {
        didSet {
            layer?.cornerRadius = cornerRadius
        }
    }
    public var roundedCorners:CACornerMask = [.layerMinXMinYCorner,
                                              .layerMinXMaxYCorner,
                                              .layerMaxXMaxYCorner,
                                              .layerMaxXMinYCorner] {
        didSet {
            layer?.maskedCorners = roundedCorners
        }
    }
    @IBInspectable public var borderWidth: CGFloat = 1 {
        didSet {
            layer?.borderWidth = borderWidth
        }
    }
    @IBInspectable public var borderColor: NSColor = .darkGray {
        didSet {
            updateColors(state == .on)
        }
    }
    @IBInspectable public var borderColorActive: NSColor = .white {
        didSet {
            updateColors(state == .on)
        }
    }
    @IBInspectable public var buttonColor: NSColor = .clear {
        didSet {
            updateColors(state == .on)
        }
    }
    @IBInspectable public var buttonColorActive: NSColor = .clear {
        didSet {
            updateColors(state == .on)
        }
    }
    @IBInspectable public var iconColor: NSColor = .white {
        didSet {
            updateColors(state == .on)
        }
    }
    @IBInspectable public var iconColorActive: NSColor = .lightGray {
        didSet {
            updateColors(state == .on)
        }
    }
    @IBInspectable public var textColor: NSColor = .gray {
        didSet {
            updateColors(state == .on)
        }
    }
    @IBInspectable public var textColorActive: NSColor = .gray {
        didSet {
            updateColors(state == .on)
        }
    }
    
    override open var title: String {
        didSet {
            setupTitle()
        }
    }
    override open var font: NSFont? {
        didSet {
            setupTitle()
        }
    }
    override open var frame: NSRect {
        didSet {
            positionTitleAndImage()
        }
    }
    override open var image: NSImage? {
        didSet {
            setupPrimaryImage(image)
        }
    }
    @IBInspectable public var overImage: NSImage? {
        didSet {
        }
    }
    override open var alternateImage: NSImage? {
        didSet {
            setupAlternateImage(alternateImage)
        }
    }
    override open var isEnabled: Bool {
        didSet {
            let alpha = Float(isEnabled ? 1.0 : 0.25)
            layer?.opacity = alpha
            updateColors(state == .on)
        }
    }
    
    // MARK: Setup & Initialization
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        setup()
    }
    
    
    
    internal func setup() {
        wantsLayer = true
        layer?.masksToBounds = false
        containerLayer.masksToBounds = false
        layer?.cornerRadius = 4
        layer?.borderWidth = 1
        layer?.delegate = self
        //containerLayer.backgroundColor = NSColor.blue.withAlphaComponent(0.1).cgColor
        //titleLayer.backgroundColor = NSColor.red.withAlphaComponent(0.2).cgColor
        titleLayer.delegate = self
        if let scale = window?.backingScaleFactor {
            titleLayer.contentsScale = scale
        }
        primaryIconLayer.delegate = self
        alternateIconLayer.delegate = self
        primaryIconLayer.masksToBounds = true
        alternateIconLayer.masksToBounds = true
        containerLayer.shadowOffset = NSSize.zero
        containerLayer.shadowColor = NSColor.clear.cgColor
        containerLayer.frame = NSMakeRect(0, 0, bounds.width, bounds.height)
        containerLayer.addSublayer(primaryIconLayer)
        containerLayer.addSublayer(alternateIconLayer)
        containerLayer.addSublayer(titleLayer)
        layer?.addSublayer(containerLayer)
        setupTitle()
        setupImages(primaryImage: self.image, alternateImage: self.alternateImage)
        setupTrackingArea()
    }
    
    
    
    internal func setupTitle() {
        guard let font = font else {
            return
        }
        titleLayer.string = title
        titleLayer.font = font
        titleLayer.fontSize = font.pointSize
        positionTitleAndImage()
    }
    
    
    internal func setupImages(primaryImage:NSImage?, alternateImage:NSImage?) {
        setupPrimaryImage(primaryImage)
        setupAlternateImage(alternateImage)
    }
    
    
    
    internal func setupPrimaryImage(_ primaryImage:NSImage?) {
        
        guard let image = primaryImage else {
            return
        }
    
        setupImageScale(primaryImage)
        
        let maskLayer = CALayer()
        let imageSize = image.size
        var imageRect:CGRect = NSMakeRect(0, 0, imageSize.width, imageSize.height)
        let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
        maskLayer.contents = imageRef
        primaryIconLayer.frame = imageRect
        maskLayer.frame = imageRect
        primaryIconLayer.mask = maskLayer
        //maskLayer.backgroundColor = NSColor.green.withAlphaComponent(0.5).cgColor
        positionTitleAndImage()
    }
    

    internal func setupAlternateImage(_ alternateImage:NSImage?) {
        guard let altImage = alternateImage else {
            return
        }
        setupImageScale(altImage)
        let altMaskLayer = CALayer()
        let altImageSize = altImage.size
        var altImageRect:CGRect = NSMakeRect(0, 0, altImageSize.width, altImageSize.height)
        let altImageRef = altImage.cgImage(forProposedRect: &altImageRect, context: nil, hints: nil)
        altMaskLayer.contents = altImageRef
        alternateIconLayer.frame = altImageRect
        altMaskLayer.frame = altImageRect
        alternateIconLayer.mask = altMaskLayer
        //altMaskLayer.backgroundColor = NSColor.green.withAlphaComponent(0.5).cgColor
        positionTitleAndImage()
    }
  
  
    
    //Currently assumes image is full-frame (or else scaling set to none)
    internal func setupImageScale(_ image: NSImage?) {
        
        guard let img = image else {
            return
        }
        
        switch  imageScaling {

        case .scaleProportionallyDown:
            
            if (img.size.width > frame.size.width) {
                let rescaleFactor1 = frame.size.width / img.size.width
                img.size.width *= rescaleFactor1
                img.size.height *= rescaleFactor1
            }
            if (img.size.height > frame.size.height) {
                let rescaleFactor2 = frame.size.height / img.size.height
                img.size.width *= rescaleFactor2
                img.size.height *= rescaleFactor2
            }
            break
            
        case .scaleProportionallyUpOrDown:
            
            //If image won't fit in frame, scale down
            if (img.size.width > frame.size.width || img.size.height > frame.size.height) {
                if (img.size.width > frame.size.width) {
                    let rescaleFactor1 = frame.size.width / img.size.width
                    img.size.width *= rescaleFactor1
                    img.size.height *= rescaleFactor1
                }
                if (img.size.height > frame.size.height) {
                    let rescaleFactor2 = frame.size.height / img.size.height
                    img.size.width *= rescaleFactor2
                    img.size.height *= rescaleFactor2
                }
            }
            //If image smaller than frame, scale up
            if (img.size.width < frame.size.width && img.size.height < frame.size.height) {
                if (img.size.width < frame.size.width) {
                    let rescaleFactor1 = frame.size.width / img.size.width
                    img.size.width *= rescaleFactor1
                    img.size.height *= rescaleFactor1
                }
                if (img.size.height < frame.size.height) {
                    let rescaleFactor2 = frame.size.height / img.size.height
                    img.size.width *= rescaleFactor2
                    img.size.height *= rescaleFactor2
                }
            }
            break
            
        case .scaleAxesIndependently:
            if (img.size.width > frame.size.width) {
                img.size.width = frame.size.width
            }
            if (img.size.height > frame.size.height) {
                img.size.height = frame.size.height
            }
            break
        default:
            break
        }
    }
    
    

    //Currently assumes image is full-frame (or else scaling set to none)
    func positionTitleAndImage() {
        
        let attributes = [NSAttributedString.Key.font: font as Any]
        
        let titleSize = title.size(withAttributes: attributes)
        var titleRect = NSMakeRect(0, 0, titleSize.width, titleSize.height)
        var imageRect = primaryIconLayer.frame
        //let hSpacing = round((bounds.width-(imageRect.width+titleSize.width))/3)
        let vSpacing = round((bounds.height-(imageRect.height+titleSize.height))/3)
        
        switch imagePosition {
        case .imageOnly:
            imageRect.origin.x = round((self.bounds.width - imageRect.size.width) / 2)
            imageRect.origin.y = round((self.bounds.height - imageRect.size.height) / 2)
            break
        case .imageAbove:
            titleRect.origin.y = bounds.height-titleRect.height - 2
            titleRect.origin.x = round((bounds.width - titleSize.width)/2)
            imageRect.origin.y = vSpacing
            imageRect.origin.x = round((bounds.width - imageRect.width)/2)
            break
        case .imageBelow:
            titleRect.origin.y = 2
            titleRect.origin.x = round((bounds.width - titleSize.width)/2)
            imageRect.origin.y = bounds.height-vSpacing-imageRect.height
            imageRect.origin.x = round((bounds.width - imageRect.width)/2)
            break
        case .imageLeft:
            //Keeps text centered wrt button, so text for popup menus doesn't jump
            titleRect.origin.y = round((bounds.height - titleSize.height)/2)
            titleRect.origin.x = round((bounds.width - titleSize.width)/2)
            imageRect.origin.y = round((bounds.height - imageRect.height)/2)
            imageRect.origin.x = cornerRadius
            break
        case .imageRight:
            //Keeps text centered wrt button, so text for popup menus doesn't jump
            titleRect.origin.y = round((bounds.height - titleSize.height)/2)
            titleRect.origin.x = round((bounds.width - titleSize.width)/2)
            imageRect.origin.y = round((bounds.height - imageRect.height)/2)
            imageRect.origin.x = bounds.width - imageRect.width - cornerRadius
            break
        //.imageTrailing, .imageLeading and many other cases not covered...
        default:
            titleRect.origin.y = round((bounds.height - titleSize.height)/2)
            titleRect.origin.x = round((bounds.width - titleSize.width)/2)
            break
        }
        primaryIconLayer.frame = imageRect
        alternateIconLayer.frame = imageRect
        titleLayer.frame = titleRect
    }
    
    
    
    func setupTrackingArea() {
        trackingArea = NSTrackingArea(rect: bounds,
                                      options: [.activeAlways, .inVisibleRect, .mouseEnteredAndExited],
                                      owner: self,
                                      userInfo: nil)
        addTrackingArea(trackingArea)
    }
    
    
    override func updateTrackingAreas() {
        
        if let mouseLocation = self.window?.mouseLocationOutsideOfEventStream {
        
            let mouseLocation = self.convert(mouseLocation, from: nil) //Necessary?
            
            if self.bounds.contains(mouseLocation) {
                mouseEntered(with: NSEvent())
            } else {
                mouseExited(with: NSEvent())
            }
            
            super.updateTrackingAreas()
        }
    }
    
    
    public func updateColors(_ isOn: Bool) {
        
        let bgColor = isOn ? buttonColorActive.usingColorSpace(NSColorSpace.genericRGB)! : buttonColor.usingColorSpace(NSColorSpace.genericRGB)!
        let titleColor = isOn ? textColorActive : textColor
        let imageColor = isOn ? iconColorActive : iconColor
        let borderColor = isOn ? borderColorActive : self.borderColor
        
        //Hover-highlighting...
        //Could do something more clever here, or make this its own settable color...
        layer?.backgroundColor = (mouseOver && isEnabled && hoverHighlightingEnabled) ?
            bgColor.highlight(withLevel: 0.15)?.cgColor : bgColor.cgColor

        layer?.borderColor = borderColor.cgColor
        
        titleLayer.foregroundColor = titleColor.cgColor
        
        //Image
        if alternateImage == nil {
            primaryIconLayer.backgroundColor = imageColor.cgColor
        } else {
            primaryIconLayer.backgroundColor =
                isOn ? NSColor.clear.cgColor : iconColor.cgColor
            
            alternateIconLayer.backgroundColor =
                isOn ? iconColorActive.cgColor : NSColor.clear.cgColor
        }
        
        //Shadows
        if glowRadius > 0, glowOpacity > 0 {
            containerLayer.shadowColor =
                isOn ? iconColorActive.cgColor : NSColor.clear.cgColor
        }
    }
    
    
    //Interaction
    
    public func setOn(_ isOn: Bool) {
        let nextState = isOn ? NSControl.StateValue.on : NSControl.StateValue.off
        if nextState != state {
            state = nextState
            updateColors(state == .on)
        }
    }
    
    override open func mouseEntered(with event: NSEvent) {
        mouseOver = true
        if (isEnabled) {
            setupPrimaryImage(overImage)
            updateColors(state == .on)
        }
        if mouseDown {
            setOn(state == .on ? false : true)
        }
    }
    
    override open func mouseExited(with event: NSEvent) {
        mouseOver = false
        if (isEnabled) {
            setupPrimaryImage(image)
            updateColors(state == .on)
        }
        if mouseDown {
            setOn(state == .on ? false : true)
            mouseDown = false
        }
    }
    
    override open func mouseDown(with event: NSEvent) {
        if isEnabled {
            mouseDown = true
            setOn(state == .on ? false : true)
            setupPrimaryImage(image)
            updateColors(state == .on)
        }
    }
    
    override open func mouseUp(with event: NSEvent) {
        if mouseDown {
            mouseDown = false
            if momentary {
                setOn(state == .on ? false : true)
            }
            _ = target?.perform(action, with: self)
        }
    }
    
    override open func hitTest(_ point: NSPoint) -> NSView? {
        return isEnabled ? super.hitTest(point) : nil
    }
    
    
    //Drawing
    
    override open func viewDidChangeBackingProperties() {
        super.viewDidChangeBackingProperties()
        if let scale = window?.backingScaleFactor {
            titleLayer.contentsScale = scale
            layer?.contentsScale = scale
            primaryIconLayer.contentsScale = scale
            alternateIconLayer.contentsScale = scale
        }
    }
    
    open func layer(_ layer: CALayer, shouldInheritContentsScale newScale: CGFloat, from window: NSWindow) -> Bool {
        return true
    }
    
    override open func draw(_ dirtyRect: NSRect) {
        //Added this; was empty.
        //Somehow reduces problem re: buttons in the menu randomly appearing as too light.
        updateColors(state == .on)
    }
    
    override open func layout() {
        super.layout()
        positionTitleAndImage()
    }
    
    override open func updateLayer() {
        super.updateLayer()
    }
}


