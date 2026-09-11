# Reservepay SDK — iOS

Swift Package Manager distribution for iOS:

- **ReservepaySDK** — binary XCFramework, downloaded from **GitHub Releases** when SPM resolves the package
- **ReservepaySwiftUI** — SwiftUI hosts for the SDK’s secure card fields

Current binary URL and checksum are in **`Package.swift`**. They must match a published [GitHub Release](https://github.com/reservepaytech/reservepay-ios/releases) tag and the **`ReservepaySDK.xcframework.zip`** asset.

## Requirements

- **iOS** 13.0 or later
- **Swift** 5.9 or later (matches `swift-tools-version` in `Package.swift`)

## Add the package (Xcode)

1. **File → Add Package Dependencies…**
2. Repository URL:

   `https://github.com/reservepaytech/reservepay-ios.git`

3. Pick a rule: **Up to Next Major** (recommended), **Exact Version**, **Branch**, or **Commit**.
4. Add the package, then under **Add to Target** link **ReservepaySDK** to your app. Add **ReservepaySwiftUI** as well if you use its SwiftUI secure-field APIs (keep **ReservepaySDK** linked).

```swift
import ReservepaySDK
import ReservepaySwiftUI   // when you add the ReservepaySwiftUI product
```

## Info.plist (required)

The host app **must** set **`CADisableMinimumFrameDurationOnPhone`** to **`YES`**. The payment UI (Compose/Skiko) expects this; omitting it can cause incorrect frame timing on device.

```xml
<key>CADisableMinimumFrameDurationOnPhone</key>
<true/>
```

In Xcode: app target → **Info** → add **`CADisableMinimumFrameDurationOnPhone`**, type **Boolean**, value **YES**.

## SDK setup

Call **`configure`** once at launch, before any other SDK API (`startPayment`, `getInstallations`, tokenize, and so on). Typical place: your `App` type’s `init`.

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

`isDebug: true` enables SDK HTTP and error logging.

---

## Usage

Two styles:

- **Built-in payment UI** — the SDK presents checkout (`startPayment`). Use when you do not build custom payment screens.
- **Custom UI** — your app owns the UX and calls the APIs below (`getInstallations`, `selectPaymentMethod`, etc.). Combine with **custom secure UI** (tokenize) when you collect cards in your own layout; use **ReservepaySwiftUI** for SwiftUI integration helpers where applicable.

### Built-in payment UI (`startPayment`)

Needs a **`UIViewController`** to present from. **Amount** is **`Int64`** in the **smallest currency unit** (for example satang for THB), not a decimal string.

`onPaymentSessionReady` receives **`(sessionId, savedCardToken)`**. `savedCardToken` is set when the shopper pays with a **new** card and chooses to save it; it is `nil` for an already-saved card or when save-card is off.

Optional **`tokens`**: saved-card tokens you persisted (or `nil`). Optional **`interestBearer`**: `InterestBearer.merchant`, `InterestBearer.customer`, or `nil` to use the installation’s `interest_bearer`.

```swift
import ReservepaySDK
import UIKit

let callback = ReservepayCallback(
    onPaymentSessionReady: { sessionId, savedCardToken in
        // Persist sessionId; persist savedCardToken when non-nil for later payments.
    },
    onPaymentCancelled: {},
    onPaymentStatus: { status in },
    onPaymentError: { error in }
)

ReservepaySDK.companion.getInstance().startPayment(
    viewController: viewController,
    amount: 150_050,
    currency: "THB",
    tokens: ["SAVED_CARD_TOKEN"],  // or nil
    interestBearer: InterestBearer.merchant,  // or .customer, or nil
    callback: callback
)
```

### Custom UI — payment APIs

Call **`configure`** first. Typical flow:

1. **`getInstallations`**
2. Then, based on the method the shopper chose:
   - **PromptPay, bank, and other non-card methods** — **`selectPaymentMethod`** with that method
   - **Card** — tokenize (or **`rehydrateCard`** for a saved card), then **`selectPaymentMethod`** with `paymentMethod: "CARD"`
   - **Installment** — tokenize first (or **`rehydrateCard`**), then **`listInstallmentPlans`**, then **`selectPaymentMethod`** with `paymentMethod: "INSTALLMENT"` and an `installmentPlanId`
3. **`processPaymentNextStep`**
4. **`checkTransactionStatus`** / **`retrievePaymentSession`** as needed

#### Get installations

Returns installation settings, including available payment methods and capture flags.

```swift
Task {
    do {
        let installation = try await ReservepaySDK.companion.getInstance().getInstallations()
        // installation.installationId, .identifier, .paymentMethods, .interestBearer, …
    } catch {
        // ReservepayException or other Error
    }
}
```

#### Select payment method

Creates a payment session. Use the method id from **`getInstallations`** (for example PromptPay or bank needs no **`token`**). For **card**, pass a **`token`** from tokenize (or rehydrate). For **installments**, also pass **`interestBearer`** (`"merchant"` or `"customer"`) and **`installmentPlanId`** from **`listInstallmentPlans`**. Optional contact and **`BillingAddress`**.

```swift
let billingAddress = BillingAddress(
    streetAddress1: nil,
    streetAddress2: nil,
    postalCode: nil,
    city: nil,
    state: nil,
    country: nil
)

let sessionId = try await ReservepaySDK.companion.getInstance().selectPaymentMethod(
    amount: 150_050,
    currency: "THB",
    paymentMethod: "CARD",  // or "INSTALLMENT", or another method from getInstallations
    interestBearer: nil,
    installmentPlanId: nil,
    token: cardToken,
    email: nil,
    mobile: nil,
    billingAddress: billingAddress
)
```

#### Process payment next step

Returns **`PaymentResult`**: QR payload, redirect URL, or a status.

```swift
let result = try await ReservepaySDK.companion.getInstance().processPaymentNextStep(
    paymentSessionId: sessionId
)

if let qr = result as? PaymentResult.QRDetails {
    _ = qr.qrData
} else if let redirect = result as? PaymentResult.RedirectDetails {
    _ = redirect.url
} else if let status = result as? PaymentResult.Status {
    _ = status.status.value  // INITIATED, PENDING, SUCCESSFUL, FAILED
}
```

#### Check transaction status

```swift
let status = try await ReservepaySDK.companion.getInstance().checkTransactionStatus(
    paymentSessionId: sessionId
)
_ = status.value
```

#### Retrieve payment session

```swift
let session = try await ReservepaySDK.companion.getInstance().retrievePaymentSession(
    paymentSessionId: sessionId
)
_ = (session.amount, session.currency, session.paymentMethod, session.status)
```

#### Rehydrate a saved card

Use a **saved-card token** plus the shopper’s security code to obtain a new token for payment.

```swift
let token = try await ReservepaySDK.companion.getInstance().rehydrateCard(
    token: savedCardToken,
    securityCode: cvv
)
```

#### List installment plans

Tokenize first, then pass amount, currency, interest bearer (`"merchant"` or `"customer"`), and the card token.

```swift
let plans = try await ReservepaySDK.companion.getInstance().listInstallmentPlans(
    amount: 150_050,
    currency: "THB",
    interestBearer: "merchant",
    token: cardToken
)
// plan.installmentPlanId, .name, .bankName, .months, .interestRate,
// .monthlyAmount, .totalAmount, .currency
```

### Custom secure UI — tokenize card

Collect card data in **your** layout using the SDK’s secure fields. The SDK validates input and returns a **card token**.

For SwiftUI, add **ReservepaySwiftUI** and use the provided hosting / appearance APIs alongside **ReservepaySDK**.

Placeholder-only hosts such as **`CardNumberFieldHost("Card Number")`**, **`ExpiryFieldHost("MM/YY")`**, **`CvvFieldHost("CVV")`**, and **`NameOnCardFieldHost("Name on card")`** own their own facades — fine for display. For tokenize, use the **`field:`** overload so the same instances are passed to tokenize.

```swift
import SwiftUI
import ReservepaySwiftUI

private final class SecureCardFieldHosts: ObservableObject {
    let cardNumber = ReservepayCardNumberField()
    let expiry = ReservepayExpiryField()
    let cvv = ReservepayCvvField()
    let name = ReservepayNameOnCardField()

    init() {
        cardNumber.setHint(text: "Card Number")
        expiry.setHint(text: "MM/YY")
        cvv.setHint(text: "CVV")
        name.setHint(text: "Name on card")
        cardNumber.setLinkedCvvField(cvv: cvv)
    }
}

struct TokenizeCardFormView: View {
    @StateObject private var fields = SecureCardFieldHosts()
    @State private var message: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            CardNumberFieldHost(field: fields.cardNumber)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            ExpiryFieldHost(field: fields.expiry)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            CvvFieldHost(field: fields.cvv)
                .frame(maxWidth: .infinity)
                .frame(height: 48)
            NameOnCardFieldHost(field: fields.name)
                .frame(maxWidth: .infinity)
                .frame(height: 48)

            Button("Tokenize") {
                let callback = ReservepayTokenCallback(
                    onSuccess: { token in message = token },
                    onFailed: { err in message = String(describing: err) },
                    onLoading: { _ in }
                )
                SecureCardFieldsTokenize.shared.tokenize(
                    cardNumber: fields.cardNumber,
                    expiry: fields.expiry,
                    cvv: fields.cvv,
                    nameOnCard: fields.name,
                    saveCard: false,
                    streetAddress1: nil,
                    streetAddress2: nil,
                    postalCode: nil,
                    city: nil,
                    state: nil,
                    country: nil,
                    paymentMethod: "CARD",  // or "INSTALLMENT"
                    callback: callback
                )
            }
            if let message { Text(message).font(.caption).foregroundStyle(.secondary) }
        }
    }
}
```

After success you can call **`SecureCardFieldsTokenize.shared.clearSensitiveFields(cardNumber:expiry:cvv:)`**. Pass the token to **`selectPaymentMethod`**, or persist it when **`saveCard`** is true and later pass it as **`tokens`** to **`startPayment`** (rehydrate with CVV when the shopper pays again).

---

## Errors

Handle **`Error`** in **`catch`** (and callback error parameters). Structured API failures (for example HTTP 400 with the SDK error body) are thrown as **`ReservepayException`**. Network and other failures may surface as a generic **`Error`**. Tokenize uses **`ReservepayTokenCallback`** (`onSuccess` / `onFailed` / optional `onLoading`).
