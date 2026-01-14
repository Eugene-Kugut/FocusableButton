import AppKit

final class NoFocusClickView: NSView {

    var onMouseDown: (() -> Void)?
    var onClick: (() -> Void)?
    var onPressChanged: ((Bool) -> Void)?
    var onHoverChanged: ((Bool) -> Void)?

    var triggerOnMouseDown: Bool = false

    private var tracking: NSTrackingArea?

    override var acceptsFirstResponder: Bool { false }

    override func hitTest(_ point: NSPoint) -> NSView? {
        self
    }

    override func updateTrackingAreas() {
        super.updateTrackingAreas()

        if let tracking { removeTrackingArea(tracking) }

        let t = NSTrackingArea(
            rect: bounds,
            options: [
                .mouseEnteredAndExited,
                .activeInKeyWindow,
                .inVisibleRect
            ],
            owner: self,
            userInfo: nil
        )
        addTrackingArea(t)
        tracking = t
    }

    override func mouseEntered(with event: NSEvent) {
        onHoverChanged?(true)
        super.mouseEntered(with: event)
    }

    override func mouseExited(with event: NSEvent) {
        onHoverChanged?(false)
        super.mouseExited(with: event)
    }

    override func mouseDown(with event: NSEvent) {
        // Mouse interaction must NOT put keyboard focus on this control.
        window?.makeFirstResponder(nil)

        onMouseDown?()
        updatePressed(isInside: true)

        if triggerOnMouseDown {
            DispatchQueue.main.async { [weak self] in
                self?.onClick?()
            }
        }

        trackUntilMouseUp()

        updatePressed(isInside: false)
    }

    override func rightMouseDown(with event: NSEvent) { mouseDown(with: event) }
    override func otherMouseDown(with event: NSEvent) { mouseDown(with: event) }

    private func trackUntilMouseUp() {
        guard let window else { return }

        while true {
            guard let next = window.nextEvent(
                matching: [
                    .leftMouseUp, .leftMouseDragged,
                    .rightMouseUp, .rightMouseDragged,
                    .otherMouseUp, .otherMouseDragged
                ],
                until: .distantFuture,
                inMode: .eventTracking,
                dequeue: true
            ) else { continue }

            let location = convert(next.locationInWindow, from: nil)
            let isInside = bounds.contains(location)
            updatePressed(isInside: isInside)

            switch next.type {
            case .leftMouseUp, .rightMouseUp, .otherMouseUp:
                if !triggerOnMouseDown, isInside {
                    onClick?()
                }
                return

            case .leftMouseDragged, .rightMouseDragged, .otherMouseDragged:
                continue

            default:
                continue
            }
        }
    }

    private func updatePressed(isInside: Bool) {
        onPressChanged?(isInside)
    }
}
