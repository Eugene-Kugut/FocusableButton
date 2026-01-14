import AppKit

final class NoFocusClickView: NSView {
    var onClick: (() -> Void)?
    var onPressChanged: ((Bool) -> Void)?
    var triggerOnMouseDown: Bool = false

    override var acceptsFirstResponder: Bool { false }
    override func hitTest(_ point: NSPoint) -> NSView? { self }

    override func mouseDown(with event: NSEvent) {
        // Clicking should NOT move keyboard focus to this view.
        // Also, in "mouse mode" we want to clear responder chain from other controls.
        window?.makeFirstResponder(nil)

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
