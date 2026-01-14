import Foundation

/// Global "keyboard navigation mode".
/// - true  -> show focus rings for package controls and allow them to participate in key loop.
/// - false -> mouse-first mode: hide focus rings and remove controls from key loop.
@MainActor
final class KeyboardFocusMode: ObservableObject {
    static let shared = KeyboardFocusMode()
    @Published var isKeyboardMode: Bool = false
    private init() {}
}
