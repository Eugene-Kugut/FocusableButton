import AppKit

enum TabTraversalDirection {
    case previous
    case next
}

final class ButtonKeyHostView: NSView {

    var onFocusChange: ((Bool) -> Void)?
    var onKeyboardInteraction: (() -> Void)?
    var onActivate: (() -> Void)?
    var onTabTraversalIn: ((TabTraversalDirection) -> Void)?

    var lastClearToken: UUID = UUID()

    override var acceptsFirstResponder: Bool { true }
    override var canBecomeKeyView: Bool { true }

    override func viewDidMoveToWindow() {
        super.viewDidMoveToWindow()
        window?.recalculateKeyViewLoop()
    }

    override func becomeFirstResponder() -> Bool {
        let ok = super.becomeFirstResponder()
        guard ok else { return false }

        onFocusChange?(true)

        // If we entered because of Tab traversal -> enable focus visuals.
        if let event = NSApp.currentEvent,
           event.type == .keyDown,
           event.keyCode == 48 { // Tab
            let direction: TabTraversalDirection = event.modifierFlags.contains(.shift) ? .previous : .next
            onKeyboardInteraction?()
            onTabTraversalIn?(direction)
        }

        return true
    }

    override func resignFirstResponder() -> Bool {
        let ok = super.resignFirstResponder()
        if ok { onFocusChange?(false) }
        return ok
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 48: // Tab
            onKeyboardInteraction?()
            moveFocusOut(with: event)

        case 49 /* Space */, 36 /* Return */, 76 /* Enter */:
            onKeyboardInteraction?()
            onActivate?()

        default:
            super.keyDown(with: event)
        }
    }

    private func moveFocusOut(with event: NSEvent) {
        guard let window else { return }

        let isBackward = event.modifierFlags.contains(.shift)
        let before = window.firstResponder

        if isBackward {
            window.selectPreviousKeyView(self)
        } else {
            window.selectNextKeyView(self)
        }

        let after = window.firstResponder

        // If this control is the only key-view (or focus didn't leave) -> wrap to self.
        if after == nil || after === before || after === self {
            window.makeFirstResponder(self)
        }
    }
}
