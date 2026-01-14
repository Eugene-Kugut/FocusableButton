import SwiftUI
import AppKit

struct NoFocusClickOverlay: NSViewRepresentable {
    let triggerOnMouseDown: Bool
    let onClick: () -> Void
    let onPressChanged: (Bool) -> Void

    func makeNSView(context: Context) -> NoFocusClickView {
        let view = NoFocusClickView()
        view.onClick = onClick
        view.onPressChanged = onPressChanged
        view.triggerOnMouseDown = triggerOnMouseDown
        view.wantsLayer = true
        view.layer?.backgroundColor = NSColor.clear.cgColor
        return view
    }

    func updateNSView(_ nsView: NoFocusClickView, context: Context) {
        nsView.onClick = onClick
        nsView.onPressChanged = onPressChanged
        nsView.triggerOnMouseDown = triggerOnMouseDown
    }
}
