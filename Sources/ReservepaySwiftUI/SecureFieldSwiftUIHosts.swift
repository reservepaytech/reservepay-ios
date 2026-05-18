import SwiftUI
import UIKit
@_exported import ReservepaySDK

/// Normal / error fill, border, and shape for secure fields (maps to Kotlin `setChromeStyle`).
/// `nil` for `cornerRadius` / `borderWidth` keeps SDK defaults (8 pt radius, 1 pt border). Use `0` for square corners.
public struct ReservepaySecureFieldAppearance: Sendable {
    public var normalBackground: UIColor?
    public var errorBackground: UIColor?
    public var normalStroke: UIColor?
    public var errorStroke: UIColor?
    public var cornerRadius: Double?
    public var borderWidth: Double?

    public init(
        normalBackground: UIColor? = nil,
        errorBackground: UIColor? = nil,
        normalStroke: UIColor? = nil,
        errorStroke: UIColor? = nil,
        cornerRadius: Double? = nil,
        borderWidth: Double? = nil
    ) {
        self.normalBackground = normalBackground
        self.errorBackground = errorBackground
        self.normalStroke = normalStroke
        self.errorStroke = errorStroke
        self.cornerRadius = cornerRadius
        self.borderWidth = borderWidth
    }
}

/// Former name for ``ReservepaySecureFieldAppearance``; prefer the new type in new code.
@available(*, deprecated, message: "Renamed to ReservepaySecureFieldAppearance.")
public typealias ReservepaySecureFieldChromeStyle = ReservepaySecureFieldAppearance

/// Kotlin `Double?` on exported APIs is `KotlinDouble?`, not Swift `Double?`.
private func kotlinDouble(_ value: Double?) -> KotlinDouble? {
    guard let value else { return nil }
    return KotlinDouble(double: value)
}

// MARK: - LocalizedStringKey → placeholder (matches `Text(_:)` for literals)

private extension LocalizedStringKey {
    /// Supports string-literal keys the same way `Text(_:)` does; uses reflection (no `String(localized: LocalizedStringKey)` overload in all SDKs).
    func resolvedForFieldPlaceholder() -> String {
        let mirror = Mirror(reflecting: self)
        for child in mirror.children {
            if child.label == "key", let s = child.value as? String { return s }
        }
        return ""
    }
}

// MARK: - UIKit bridge

/// Embeds an existing `UIViewController` (e.g. from Kotlin `viewController`) in SwiftUI.
public struct ReservepayUIViewControllerAdapter: UIViewControllerRepresentable {
    public let viewController: UIViewController

    public init(viewController: UIViewController) {
        self.viewController = viewController
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        viewController
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}

// MARK: - Shared shell (tokenize / pre-built facades)

private struct SharedFacadeFieldHost: View {
    let viewController: UIViewController

    var body: some View {
        ReservepayUIViewControllerAdapter(viewController: viewController)
            .contentShape(Rectangle())
    }
}

// MARK: - Card number

public struct CardNumberFieldHost: View {
    private let content: AnyView

    /// Verbatim placeholder string (not localized).
    public init(_ placeholder: String, appearance: ReservepaySecureFieldAppearance = ReservepaySecureFieldAppearance()) {
        content = AnyView(_OwnedCardNumberFieldHost(placeholder: placeholder, appearance: appearance))
    }

    /// Same shape as `Text(_:)` / `LocalizedStringKey` for localized placeholders.
    public init(_ key: LocalizedStringKey, appearance: ReservepaySecureFieldAppearance = ReservepaySecureFieldAppearance()) {
        self.init(key.resolvedForFieldPlaceholder(), appearance: appearance)
    }

    public init(field: ReservepayCardNumberField) {
        content = AnyView(SharedFacadeFieldHost(viewController: field.viewController))
    }

    public var body: some View { content }
}

private struct _OwnedCardNumberFieldHost: View {
    @State private var box: KotlinCardNumberFieldBox

    init(placeholder: String, appearance: ReservepaySecureFieldAppearance) {
        _box = State(initialValue: KotlinCardNumberFieldBox(placeholder: placeholder, appearance: appearance))
    }

    var body: some View {
        SharedFacadeFieldHost(viewController: box.field.viewController)
    }
}

private final class KotlinCardNumberFieldBox: ObservableObject {
    let field: ReservepayCardNumberField
    init(placeholder: String, appearance: ReservepaySecureFieldAppearance) {
        field = ReservepayCardNumberField()
        field.setHint(text: placeholder)
        field.setChromeStyle(
            normalBackground: appearance.normalBackground,
            errorBackground: appearance.errorBackground,
            normalStroke: appearance.normalStroke,
            errorStroke: appearance.errorStroke,
            cornerRadius: kotlinDouble(appearance.cornerRadius),
            borderWidth: kotlinDouble(appearance.borderWidth)
        )
    }
}

// MARK: - Expiry

public struct ExpiryFieldHost: View {
    private let content: AnyView

    public init(_ placeholder: String, appearance: ReservepaySecureFieldAppearance = ReservepaySecureFieldAppearance()) {
        content = AnyView(_OwnedExpiryFieldHost(placeholder: placeholder, appearance: appearance))
    }

    public init(_ key: LocalizedStringKey, appearance: ReservepaySecureFieldAppearance = ReservepaySecureFieldAppearance()) {
        self.init(key.resolvedForFieldPlaceholder(), appearance: appearance)
    }

    public init(field: ReservepayExpiryField) {
        content = AnyView(SharedFacadeFieldHost(viewController: field.viewController))
    }

    public var body: some View { content }
}

private struct _OwnedExpiryFieldHost: View {
    @State private var box: KotlinExpiryFieldBox

    init(placeholder: String, appearance: ReservepaySecureFieldAppearance) {
        _box = State(initialValue: KotlinExpiryFieldBox(placeholder: placeholder, appearance: appearance))
    }

    var body: some View {
        SharedFacadeFieldHost(viewController: box.field.viewController)
    }
}

private final class KotlinExpiryFieldBox: ObservableObject {
    let field: ReservepayExpiryField
    init(placeholder: String, appearance: ReservepaySecureFieldAppearance) {
        field = ReservepayExpiryField()
        field.setHint(text: placeholder)
        field.setChromeStyle(
            normalBackground: appearance.normalBackground,
            errorBackground: appearance.errorBackground,
            normalStroke: appearance.normalStroke,
            errorStroke: appearance.errorStroke,
            cornerRadius: kotlinDouble(appearance.cornerRadius),
            borderWidth: kotlinDouble(appearance.borderWidth)
        )
    }
}

// MARK: - CVC

public struct CvcFieldHost: View {
    private let content: AnyView

    public init(_ placeholder: String, appearance: ReservepaySecureFieldAppearance = ReservepaySecureFieldAppearance()) {
        content = AnyView(_OwnedCvcFieldHost(placeholder: placeholder, appearance: appearance))
    }

    public init(_ key: LocalizedStringKey, appearance: ReservepaySecureFieldAppearance = ReservepaySecureFieldAppearance()) {
        self.init(key.resolvedForFieldPlaceholder(), appearance: appearance)
    }

    public init(field: ReservepayCvcField) {
        content = AnyView(SharedFacadeFieldHost(viewController: field.viewController))
    }

    public var body: some View { content }
}

private struct _OwnedCvcFieldHost: View {
    @State private var box: KotlinCvcFieldBox

    init(placeholder: String, appearance: ReservepaySecureFieldAppearance) {
        _box = State(initialValue: KotlinCvcFieldBox(placeholder: placeholder, appearance: appearance))
    }

    var body: some View {
        SharedFacadeFieldHost(viewController: box.field.viewController)
    }
}

private final class KotlinCvcFieldBox: ObservableObject {
    let field: ReservepayCvcField
    init(placeholder: String, appearance: ReservepaySecureFieldAppearance) {
        field = ReservepayCvcField()
        field.setHint(text: placeholder)
        field.setChromeStyle(
            normalBackground: appearance.normalBackground,
            errorBackground: appearance.errorBackground,
            normalStroke: appearance.normalStroke,
            errorStroke: appearance.errorStroke,
            cornerRadius: kotlinDouble(appearance.cornerRadius),
            borderWidth: kotlinDouble(appearance.borderWidth)
        )
    }
}

// MARK: - Name on card

public struct NameOnCardFieldHost: View {
    private let content: AnyView

    public init(_ placeholder: String, appearance: ReservepaySecureFieldAppearance = ReservepaySecureFieldAppearance()) {
        content = AnyView(_OwnedNameFieldHost(placeholder: placeholder, appearance: appearance))
    }

    public init(_ key: LocalizedStringKey, appearance: ReservepaySecureFieldAppearance = ReservepaySecureFieldAppearance()) {
        self.init(key.resolvedForFieldPlaceholder(), appearance: appearance)
    }

    public init(field: ReservepayNameOnCardField) {
        content = AnyView(SharedFacadeFieldHost(viewController: field.viewController))
    }

    public var body: some View { content }
}

private struct _OwnedNameFieldHost: View {
    @State private var box: KotlinNameOnCardFieldBox

    init(placeholder: String, appearance: ReservepaySecureFieldAppearance) {
        _box = State(initialValue: KotlinNameOnCardFieldBox(placeholder: placeholder, appearance: appearance))
    }

    var body: some View {
        SharedFacadeFieldHost(viewController: box.field.viewController)
    }
}

private final class KotlinNameOnCardFieldBox: ObservableObject {
    let field: ReservepayNameOnCardField
    init(placeholder: String, appearance: ReservepaySecureFieldAppearance) {
        field = ReservepayNameOnCardField()
        field.setHint(text: placeholder)
        field.setChromeStyle(
            normalBackground: appearance.normalBackground,
            errorBackground: appearance.errorBackground,
            normalStroke: appearance.normalStroke,
            errorStroke: appearance.errorStroke,
            cornerRadius: kotlinDouble(appearance.cornerRadius),
            borderWidth: kotlinDouble(appearance.borderWidth)
        )
    }
}
