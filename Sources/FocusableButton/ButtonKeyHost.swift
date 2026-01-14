import SwiftUI
import AppKit

struct ButtonKeyHost: NSViewRepresentable {
    @Binding var isFocused: Bool

    let clearFocusToken: UUID

    let onKeyboardInteraction: () -> Void
    let onFocusInByTabTraversal: (TabTraversalDirection) -> Void
    let onActivate: () -> Void
    let onFocusOut: () -> Void

    func makeNSView(context: Context) -> ButtonKeyHostView {
        let v = ButtonKeyHostView()
        v.focusRingType = .none
        applyCallbacks(to: v)
        v.lastClearToken = clearFocusToken
        return v
    }

    func updateNSView(_ nsView: ButtonKeyHostView, context: Context) {
        applyCallbacks(to: nsView)

        // Force resign if requested (outside click, mouse interaction, etc.)
        if nsView.lastClearToken != clearFocusToken {
            nsView.lastClearToken = clearFocusToken
            DispatchQueue.main.async {
                guard let window = nsView.window else { return }
                if window.firstResponder === nsView {
                    window.makeFirstResponder(nil)
                }
            }
        }
    }

    private func applyCallbacks(to view: ButtonKeyHostView) {
        view.onKeyboardInteraction = onKeyboardInteraction
        view.onActivate = onActivate
        view.onTabTraversalIn = onFocusInByTabTraversal

        view.onFocusChange = { focused in
            DispatchQueue.main.async {
                self.isFocused = focused
                if focused == false { onFocusOut() }
            }
        }
    }
}
