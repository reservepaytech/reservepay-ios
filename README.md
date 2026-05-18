# ReservePay SDK — iOS

Swift Package Manager distribution for iOS: the **ReservepaySDK** binary (XCFramework, downloaded from **GitHub Releases** when SPM resolves the package), and **ReservepaySwiftUI** for SwiftUI secure-card field helpers when your UI needs them.

## Requirements

- **iOS** 13.0 or later  
- **Swift** 5.9 or later (matches `swift-tools-version` in `Package.swift`)
- A **published [GitHub Release](https://github.com/reservepaytech/reservepay-ios/releases)** whose tag and **`ReservepaySDK.xcframework.zip`** asset match **`Package.swift`** in this repo (otherwise Xcode cannot download the binary).

## Add the package (Xcode)

1. **File → Add Package Dependencies…**
2. Repository URL:

   `https://github.com/reservepaytech/reservepay-ios.git`

3. Pick a rule: **Up to Next Major** (recommended once release tags exist), **Branch** (e.g. `main`), or **Exact Version** / **Commit**.
4. Add the package, then under **Add to Target** link **ReservepaySDK** to your app. Add **ReservepaySwiftUI** as well if you use its SwiftUI secure-field APIs (keep **ReservepaySDK** linked).

```swift
import ReservepaySDK
import ReservepaySwiftUI   // when you add the ReservepaySwiftUI product
```

## SDK setup

Call **`configure`** once at app launch, before any other SDK APIs (for example in your `App` type’s `init`).

```swift
import ReservepaySDK

@main
struct MyApp: App {
    init() {
        ReservepaySDK.companion.getInstance().configure(
            isDebug: true,
            merchantId: "YOUR_MERCHANT_ID",
            installationId: "YOUR_INSTALLATION_ID"
        )
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
```

**Built-in payment UI:** **`startPayment`** needs a **`UIViewController`** to present the SDK payment screen.

---

## Usage

Two styles:

- **Built-in payment UI** — the SDK shows full checkout (`startPayment`). Use when you do not build custom payment screens.
- **Custom UI** — your app owns the UX and calls the APIs below (`getInstallations`, `selectPaymentMethod`, etc.). Combine with **custom secure UI** (tokenize) when you collect cards in your own layout; use **ReservepaySwiftUI** for SwiftUI integration helpers where applicable.

### Built-in payment UI (`startPayment`)

**Amount** is in the **smallest currency unit** (e.g. satang for THB), as **`Int64`**.

```swift
import ReservepaySDK

let callback = ReservepayCallback(
    onPaymentSessionReady: { sessionId in },
    onPaymentCancelled: {},
    onPaymentStatus: { status in },
    onPaymentError: { error in }
)

ReservepaySDK.companion.getInstance().startPayment(
    viewController: viewController,
    amount: 150_050,
    currency: "THB",
    callback: callback
)
```

### Custom UI — payment APIs

Call **`configure`** first. Typical flow: **`getInstallations`** → **`selectPaymentMethod`** → **`processPaymentNextStep`**, then **`checkTransactionStatus`** / **`retrievePaymentSession`** as needed.

#### Get installations

```swift
import ReservepaySDK

Task {
    do {
        let installation = try await ReservepaySDK.companion.getInstance().getInstallations()
    } catch {
    }
}
```

#### Select payment method

```swift
let sessionId = try await ReservepaySDK.companion.getInstance().selectPaymentMethod(
    amount: 150_050,
    currency: "THB",
    paymentMethod: "CARD",
    token: nil,
    email: nil,
    mobile: nil
)
```

#### Process payment next step

```swift
let result = try await ReservepaySDK.companion.getInstance().processPaymentNextStep(
    paymentSessionId: sessionId
)
```

#### Check transaction status

```swift
let status = try await ReservepaySDK.companion.getInstance().checkTransactionStatus(
    paymentSessionId: sessionId
)
```

#### Retrieve payment session

```swift
let session = try await ReservepaySDK.companion.getInstance().retrievePaymentSession(
    paymentSessionId: sessionId
)
```

### Custom secure UI — tokenize card

For **custom UI**, embed the SDK’s secure fields in **your** layouts, obtain a **card token**, and pass it into **`selectPaymentMethod`**. For SwiftUI, add **ReservepaySwiftUI** and use the provided hosting / appearance APIs alongside **ReservepaySDK**.

---

## Errors

Handle **`Error`** in **`catch`** (and any callback error parameters). Structured failures may surface as **`ReservepayException`** where the SDK defines it.
