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
    public var triggerOnMouseDown: Bool
    public let action: () -> Void

    // MARK: - Internal state

    /// True when our invisible AppKit key-host is the firstResponder.
    @State private var isKeyHostFocused: Bool = false

    /// Show focus highlight ONLY after Tab traversal entered the control.
    @State private var showsKeyboardFocus: Bool = false

    @State private var isHovered: Bool = false
    @State private var isPressed: Bool = false

    /// Forces the key-host to resign firstResponder (even if click happens on non-focusable area).
    @State private var clearFocusToken: UUID = UUID()

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
        self.triggerOnMouseDown = triggerOnMouseDown
        self.action = action
    }

    private var isVisuallyFocused: Bool {
        showsKeyboardFocus && isKeyHostFocused
    }

    private func currentBackground() -> Color {
        if isPressed { return pressedBackground }
        if isVisuallyFocused { return focusedBackground }
        if isHovered { return hoveredBackground }
        return .clear
    }

    private func currentStroke() -> Color {
        if isVisuallyFocused { return focusedOverlay }
        return .clear
    }

    private func performKeyboardPressFeedbackAndAction() {
        isPressed = true
        action()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.10) {
            isPressed = false
        }
    }

    public var body: some View {
        ZStack {
            Text(title)
                .font(font)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
        }
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(selectedBackground)
        }
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(currentBackground())
        }
        .overlay {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .strokeBorder(currentStroke(), lineWidth: 1.5)
        }

        // Mouse handling without taking keyboard focus:
        .overlay {
            NoFocusClickOverlay(
                triggerOnMouseDown: triggerOnMouseDown,
                onMouseDown: {
                    // Any mouse interaction switches off keyboard focus visuals.
                    showsKeyboardFocus = false
                    clearFocusToken = UUID()
                },
                onClick: action,
                onPressChanged: { isPressed = $0 },
                onHoverChanged: { isHovered = $0 }
            )
        }

        // Click outside: hide focus highlight and also resign firstResponder even if AppKit didn’t move it.
        .background(
            OutsideClickMonitor {
                showsKeyboardFocus = false
                isHovered = false
                isPressed = false
                clearFocusToken = UUID()
            }
            .allowsHitTesting(false)
        )

        // Invisible key-host that participates in key-view-loop:
        .overlay {
            ButtonKeyHost(
                isFocused: $isKeyHostFocused,
                clearFocusToken: clearFocusToken,
                onKeyboardInteraction: {
                    // If user is already inside the control and presses keys - keep focus visuals.
                    showsKeyboardFocus = true
                },
                onFocusInByTabTraversal: { _ in
                    // IMPORTANT: show focus only when entered by Tab traversal.
                    showsKeyboardFocus = true
                },
                onActivate: {
                    showsKeyboardFocus = true
                    performKeyboardPressFeedbackAndAction()
                },
                onFocusOut: {
                    // When focus leaves - reset visuals.
                    showsKeyboardFocus = false
                    isPressed = false
                }
            )
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .accessibilityHidden(true)
        }

        .accessibilityElement()
        .accessibilityLabel(Text(title))
        .accessibilityAddTraits(.isButton)
    }
}
