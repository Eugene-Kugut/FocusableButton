import AppKit

/// Detects input method:
/// - First Tab (when keyboard mode is OFF): enables keyboard mode and manually advances focus ONCE.
/// - Subsequent Tab: let AppKit handle normal key-loop.
/// - Any mouseDown: disables keyboard mode.
///
/// Uses a single local event monitor with ref-counted lifecycle.
@MainActor
final class KeyboardInputMethodMonitor {

    static let shared = KeyboardInputMethodMonitor()

    private var refCount: Int = 0
    private var monitor: Any?

    private init() {}

    func retain() {
        refCount += 1
        if refCount == 1 {
            install()
        }
    }

    func release() {
        refCount = max(0, refCount - 1)
        if refCount == 0 {
            uninstall()
        }
    }

    private func install() {
        guard monitor == nil else { return }

        monitor = NSEvent.addLocalMonitorForEvents(
            matching: [
                .keyDown,
                .leftMouseDown, .rightMouseDown, .otherMouseDown
            ],
            handler: { event in
                switch event.type {
                case .keyDown:
                    // Tab keyCode = 48
                    if event.keyCode == 48 {
                        let wasKeyboardMode = KeyboardFocusMode.shared.isKeyboardMode
                        let isShift = event.modifierFlags.contains(.shift)

                        // If keyboard mode is OFF, the first Tab should:
                        // 1) enable keyboard mode
                        // 2) NOT be processed by AppKit immediately (SwiftUI hasn't updated .focusable yet)
                        // 3) manually advance focus once on the next runloop tick.
                        if !wasKeyboardMode {
                            KeyboardFocusMode.shared.isKeyboardMode = true

                            DispatchQueue.main.async {
                                guard let window = event.window else { return }
                                if isShift {
                                    window.selectPreviousKeyView(nil)
                                } else {
                                    window.selectNextKeyView(nil)
                                }
                            }

                            // Swallow this Tab. We already advanced focus manually.
                            return nil
                        }

                        // Already in keyboard mode -> let AppKit handle normal Tab traversal.
                        return event
                    }

                case .leftMouseDown, .rightMouseDown, .otherMouseDown:
                    KeyboardFocusMode.shared.isKeyboardMode = false
                    return event

                default:
                    return event
                }

                return event
            }
        )
    }

    private func uninstall() {
        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
    }
}
