import SwiftUI
import AppKit

struct NoFocusClickOverlay: NSViewRepresentable {
    let triggerOnMouseDown: Bool
    let onMouseDown: () -> Void
    let onClick: () -> Void
    let onPressChanged: (Bool) -> Void
    let onHoverChanged: (Bool) -> Void

    func makeNSView(context: Context) -> NoFocusClickView {
        let v = NoFocusClickView()
        v.triggerOnMouseDown = triggerOnMouseDown
        v.onMouseDown = onMouseDown
        v.onClick = onClick
        v.onPressChanged = onPressChanged
        v.onHoverChanged = onHoverChanged
        v.wantsLayer = true
        v.layer?.backgroundColor = NSColor.clear.cgColor
        return v
    }

    func updateNSView(_ nsView: NoFocusClickView, context: Context) {
        nsView.triggerOnMouseDown = triggerOnMouseDown
        nsView.onMouseDown = onMouseDown
        nsView.onClick = onClick
        nsView.onPressChanged = onPressChanged
        nsView.onHoverChanged = onHoverChanged
    }
}
