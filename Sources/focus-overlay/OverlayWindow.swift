import AppKit

class OverlayWindow: NSWindow {
    init(message: String, onDismiss: @escaping () -> Void, onCancel: @escaping () -> Void) {
        let screenFrame = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 1920, height: 1080)

        // Calculate text size to determine window size
        let fontSize: CGFloat = 24
        let font = NSFont.systemFont(ofSize: fontSize, weight: .medium)
        let textSize = (message as NSString).size(withAttributes: [.font: font])
        let padding: CGFloat = 40
        let windowWidth = textSize.width + padding * 2
        let windowHeight: CGFloat = 60

        // Center the window on screen
        let windowX = (screenFrame.width - windowWidth) / 2 + screenFrame.origin.x
        let windowY = (screenFrame.height - windowHeight) / 2 + screenFrame.origin.y
        let windowFrame = NSRect(x: windowX, y: windowY, width: windowWidth, height: windowHeight)

        super.init(
            contentRect: windowFrame,
            styleMask: .borderless,
            backing: .buffered,
            defer: false
        )

        // Configure window properties
        self.level = .floating
        self.backgroundColor = NSColor.clear
        self.isOpaque = false
        self.hasShadow = true
        self.ignoresMouseEvents = false

        // Make window visible on all spaces
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        // Set the content view
        let overlayView = OverlayView(frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight), message: message, onDismiss: onDismiss, onCancel: onCancel)
        self.contentView = overlayView

        // Make the window key and visible
        self.makeKeyAndOrderFront(nil)
        self.makeFirstResponder(overlayView)
    }
}
