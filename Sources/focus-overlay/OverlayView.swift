import AppKit

class OverlayView: NSView {
    private let message: String
    private let onDismiss: () -> Void
    private let onCancel: () -> Void
    private var globalClickMonitor: Any?
    private var globalKeyMonitor: Any?
    private var localKeyMonitor: Any?

    init(frame: NSRect, message: String, onDismiss: @escaping () -> Void, onCancel: @escaping () -> Void) {
        self.message = message
        self.onDismiss = onDismiss
        self.onCancel = onCancel
        super.init(frame: frame)

        self.wantsLayer = true
        self.layer?.backgroundColor = NSColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 0.95).cgColor
        self.layer?.cornerRadius = 12

        setupTextLayer()
        setupGlobalMonitors()
    }

    private func setupGlobalMonitors() {
        // Monitor for any mouse click globally (when app is not focused)
        globalClickMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] _ in
            self?.onDismiss()
        }

        // Monitor for ESC/Space key globally (when app is not focused)
        globalKeyMonitor = NSEvent.addGlobalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC
                self?.onCancel()
            } else if event.keyCode == 49 { // Space
                self?.onDismiss()
            }
        }

        // Monitor for ESC/Space key locally (when app is focused)
        localKeyMonitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            if event.keyCode == 53 { // ESC
                self?.onCancel()
                return nil
            } else if event.keyCode == 49 { // Space
                self?.onDismiss()
                return nil
            }
            return event
        }
    }

    deinit {
        if let monitor = globalClickMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = globalKeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
        if let monitor = localKeyMonitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupTextLayer() {
        let fontSize: CGFloat = 24
        let font = NSFont.systemFont(ofSize: fontSize, weight: .medium)
        let textSize = (message as NSString).size(withAttributes: [.font: font])
        let x = (frame.width - textSize.width) / 2
        let y = (frame.height - textSize.height) / 2

        let textLayer = CATextLayer()
        textLayer.string = message
        textLayer.fontSize = fontSize
        textLayer.foregroundColor = NSColor.white.cgColor
        textLayer.alignmentMode = .center
        textLayer.contentsScale = NSScreen.main?.backingScaleFactor ?? 2.0
        textLayer.font = font
        textLayer.frame = CGRect(x: x, y: y, width: textSize.width, height: textSize.height)

        self.layer?.addSublayer(textLayer)
    }

    override func mouseDown(with event: NSEvent) {
        onDismiss()
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 53 { // ESC key
            onCancel()
        }
    }

    override func acceptsFirstMouse(for event: NSEvent?) -> Bool {
        return true
    }

    override var acceptsFirstResponder: Bool {
        return true
    }
}
