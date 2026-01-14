import SwiftUI

/// Installs the package-wide input monitor while a control is on screen.
struct KeyboardModeHosting: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear { KeyboardInputMethodMonitor.shared.retain() }
            .onDisappear { KeyboardInputMethodMonitor.shared.release() }
    }
}

extension View {
    /// Call this in every package control (FocusableButton/Tabs/Tags/etc)
    /// to ensure Tab/mouse detection works even if some controls are absent.
    func hostsKeyboardModeDetection() -> some View {
        modifier(KeyboardModeHosting())
    }
}
