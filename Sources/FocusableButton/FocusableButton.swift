import SwiftUI
import AppKit

public struct FocusableButton: View {
    public let title: String
    public let font: Font
    public let verticalPadding: CGFloat
    public let horizontalPadding: CGFloat
    public let cornerRadius: CGFloat
    public let selectedBackground: Color
    public let focusedBackground: Color
    public let focusedOverlay: Color
    public let hoveredBackground: Color
    public let pressedBackground: Color
    public let pressedOverlay: Color
    public var triggerOnMouseDown: Bool
    public let action: () -> Void

    @FocusState private var isFocused: Bool
    @State private var isHovered: Bool = false
    @State private var isPressed: Bool = false

    @ObservedObject private var focusMode = KeyboardFocusMode.shared

    public init(
        title: String,
        font: Font = .title3,
        verticalPadding: CGFloat = 6,
        horizontalPadding: CGFloat = 12,
        cornerRadius: CGFloat = 8,
        selectedBackground: Color = Color.primary.opacity(0.10),
        focusedBackground: Color = Color.accentColor.opacity(0.12),
        focusedOverlay: Color = Color.accentColor.opacity(0.9),
        hoveredBackground: Color = Color.primary.opacity(0.06),
        pressedBackground: Color = Color.primary.opacity(0.14),
        pressedOverlay: Color = Color.primary.opacity(0.35),
        triggerOnMouseDown: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.font = font
        self.verticalPadding = verticalPadding
        self.horizontalPadding = horizontalPadding
        self.cornerRadius = cornerRadius
        self.selectedBackground = selectedBackground
        self.focusedBackground = focusedBackground
        self.focusedOverlay = focusedOverlay
        self.hoveredBackground = hoveredBackground
        self.pressedBackground = pressedBackground
        self.pressedOverlay = pressedOverlay
        self.triggerOnMouseDown = triggerOnMouseDown
        self.action = action
    }

    private func backgroundColor() -> Color {
        if isPressed { return pressedBackground }
        if focusMode.isKeyboardMode, isFocused { return focusedBackground }
        if isHovered { return hoveredBackground }
        return .clear
    }

    private func overlayColor() -> Color {
        (focusMode.isKeyboardMode && isFocused) ? focusedOverlay : .clear
    }

    private func performKeyboardPressFeedbackAndAction() {
        isPressed = true
        action()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            isPressed = false
        }
    }

    public var body: some View {
        Text(title)
            .font(font)
            .padding(.vertical, verticalPadding)
            .padding(.horizontal, horizontalPadding)

            // ✅ Core behavior:
            // Control joins key-loop ONLY after user pressed Tab (keyboard mode).
            .focusable(focusMode.isKeyboardMode)
            .focused($isFocused)

            // We draw our own focus ring/pressed/hover styles.
            .focusEffectDisabled()

            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(selectedBackground)
            }
            .background {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .fill(backgroundColor())
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(overlayColor(), lineWidth: 1.5)
            }
            .overlay {
                NoFocusClickOverlay(
                    triggerOnMouseDown: triggerOnMouseDown,
                    onClick: action,
                    onPressChanged: { isPressed = $0 }
                )
            }
            .onHover { isHovered = $0 }

            // If we switched back to mouse mode, ensure we drop internal focus state.
            .onChange(of: focusMode.isKeyboardMode) { _, newValue in
                if !newValue, isFocused {
                    isFocused = false
                }
            }

            // Keyboard activation (when focused via Tab).
            .onKeyPress { keyPress in
                switch keyPress.key {
                case .space, .return:
                    performKeyboardPressFeedbackAndAction()
                    return .handled
                default:
                    return .ignored
                }
            }

            // ✅ Make sure Tab/mouse monitoring works even without FocusableButton on screen.
            .hostsKeyboardModeDetection()
    }
}
