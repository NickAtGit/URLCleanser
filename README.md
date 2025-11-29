# URLCleanser

A lightweight Swift package for removing tracking parameters from URLs while preserving important query parameters.

## Features

- 🧹 Remove 100+ common tracking parameters
- 🎯 Pattern-based detection for unknown trackers
- 🔒 Whitelist support to preserve internal parameters
- ⚡️ Zero dependencies
- 🎨 Clean, SwiftUI-friendly API
- ✅ Comprehensive test coverage (75+ tests)
- 📱 iOS 16+, macOS 13+ support

## Installation

### Swift Package Manager

Add URLCleanser to your project using Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/NickAtGit/URLCleanser`
3. Select branch: `main`

Or add it to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/NickAtGit/URLCleanser.git", branch: "main")
]
```

## Usage

### Basic Usage

Remove all tracking parameters from a URL:

```swift
import URLCleanser

let url = URL(string: "https://example.com/article?utm_source=facebook&utm_medium=social&id=123")!
let cleanURL = url.removingTrackingParameters()
print(cleanURL)
// Output: https://example.com/article?id=123
```

### Preserve Internal Parameters

Whitelist specific parameters you want to keep (e.g., internal tracking):

```swift
let url = URL(string: "https://example.com/card?source=app&utm_campaign=test&id=456")!
let cleaned = url.removingTrackingParameters(preserving: ["source", "id"])
print(cleaned)
// Output: https://example.com/card?source=app&id=456
```

### Check for Tracking Parameters

Detect if a URL contains tracking parameters:

```swift
let url = URL(string: "https://example.com?utm_source=fb&id=123")!
if url.containsTrackingParameters() {
    print("URL contains tracking")
}
```

### Get Tracking Parameters

Extract all tracking parameters from a URL:

```swift
let url = URL(string: "https://example.com?utm_source=fb&utm_medium=social&id=123")!
let tracking = url.trackingParameters()
print(tracking)
// Output: ["utm_source": "fb", "utm_medium": "social"]
```

### In-Place Mutation

For performance-critical scenarios with many URLs:

```swift
var urls = [URL]()
for i in urls.indices {
    urls[i].removeTrackingParameters()
}
```

## Supported Tracking Parameters

URLCleanser removes **100+ tracking parameters** organized by category:

### UTM Parameters (9)
- `utm_source`, `utm_medium`, `utm_campaign`, `utm_term`, `utm_content`
- `utm_id`, `utm_source_platform`, `utm_creative_format`, `utm_marketing_tactic`

### Social Media (25+)
- **Facebook**: `fbclid`, `fb_action_ids`, `fb_action_types`, `fb_source`, `fb_ref`
- **Google**: `gclid`, `gclsrc`, `dclid`, `gbraid`, `wbraid`
- **Microsoft**: `msclkid`, `msclid`
- **Twitter/X**: `twclid`, `tw_source`, `tw_campaign`
- **LinkedIn**: `li_fat_id`, `lipi`, `licu`
- **TikTok**: `ttclid`, `tt_medium`, `tt_content`
- **Instagram**: `igshid`, `ig_rid`
- **Pinterest**: `epik`
- **Snapchat**: `sccid`
- **Reddit**: `rdt_cid`

### Email Marketing (15+)
- **Mailchimp**: `mc_cid`, `mc_eid`
- **HubSpot**: `_hsenc`, `_hsmi`, `__hssc`, `__hstc`, `__hsfp`
- **SendGrid**: `sg_link_id`
- **Campaign Monitor**: `cm_mmc`
- **ActiveCampaign**: `vgo_ee`
- **Marketo**: `mkt_tok`

### Analytics & Tracking (30+)
- **Adobe**: `s_cid`, `adobe_mc`
- **Google Analytics**: `_ga`, `_gid`, `_gl`
- **Mixpanel**: `mp_source`, `mp_medium`, `mp_campaign`
- **Amplitude**: `amp_source`, `amp_medium`, `amp_campaign`
- **Yandex**: `yclid`, `_openstat`
- And many more...

### Affiliate & E-commerce (28+)
- **Amazon**: `tag`, `ascsubtag`, `asc_campaign`, `asc_source`, `asc_refurl`
- **eBay**: `mkcid`, `mkevt`, `mkrid`, `campid`, `toolid`
- **Apple App Store**: `pt`, `ct`, `mt` (attribution parameters)
- **Rakuten**, **ShareASale**, **Impact**, and more...

### Pattern-Based Detection
URLCleanser also uses regex patterns to catch unknown or emerging tracking parameters:
- `^utm_*` (any UTM variant)
- `^fb_*` (Facebook variants)
- `^track(ing)?_*` (tracking prefixes)
- `^analytics?_*` (analytics prefixes)

**Total Coverage**: 100+ known parameters + pattern matching

## Real-World Examples

### Preserve Internal Tracking

```swift
let url = URL(string: "https://example.com/user/profile?source=app&utm_source=facebook&fbclid=IwAR1234")!
let cleaned = url.removingTrackingParameters(preserving: ["source"])
print(cleaned)
// Output: https://example.com/user/profile?source=app
```

### App Store Share Link

Preserve Apple attribution for App Store links:

```swift
let url = URL(string: "https://apps.apple.com/app/id123?pt=106913804&ct=ShareApp&mt=8&utm_source=email")!
let cleaned = url.removingTrackingParameters(preserving: ["pt", "ct", "mt"])
print(cleaned)
// Output: https://apps.apple.com/app/id123?pt=106913804&ct=ShareApp&mt=8
```

### Mixed Tracking Parameters

```swift
let url = URL(string: "https://example.com?utm_source=fb&fbclid=abc&mc_cid=123&gclid=xyz&id=456&name=test")!
let cleaned = url.removingTrackingParameters()
print(cleaned)
// Output: https://example.com?id=456&name=test
```

## API Reference

### URL Extension Methods

#### `removingTrackingParameters(preserving:)`
```swift
func removingTrackingParameters(preserving whitelist: Set<String>? = nil) -> URL
```
Returns a new URL with tracking parameters removed. Non-mutating.

**Parameters:**
- `whitelist`: Optional set of parameter names to preserve

**Returns:** Cleaned URL or original if parsing fails

---

#### `removeTrackingParameters(preserving:)`
```swift
mutating func removeTrackingParameters(preserving whitelist: Set<String>? = nil)
```
Removes tracking parameters in-place. Mutating variant for performance.

---

#### `containsTrackingParameters(ignoring:)`
```swift
func containsTrackingParameters(ignoring whitelist: Set<String>? = nil) -> Bool
```
Checks if URL contains any tracking parameters.

**Parameters:**
- `whitelist`: Optional set of parameters to ignore when checking

**Returns:** `true` if tracking parameters are found

---

#### `trackingParameters(ignoring:)`
```swift
func trackingParameters(ignoring whitelist: Set<String>? = nil) -> [String: String?]
```
Extracts all tracking parameters from the URL.

**Parameters:**
- `whitelist`: Optional set of parameters to exclude from results

**Returns:** Dictionary of tracking parameter names to values

## Integration Tips

### Recommended Whitelist Pattern

```swift
extension URL {
    static let internalTrackingWhitelist: Set<String> = [
        "source",  // Internal tracking
        "id",      // Resource identifier
    ]

    func removingExternalTracking() -> URL {
        if absoluteString.contains("apps.apple.com") {
            // Preserve Apple attribution for App Store links
            return removingTrackingParameters(preserving: ["pt", "ct", "mt"])
        } else {
            // Preserve only internal tracking for other URLs
            return removingTrackingParameters(preserving: Self.internalTrackingWhitelist)
        }
    }
}
```

### Where to Use URLCleanser

**✅ Good Use Cases:**
- External URL sharing
- URL storage before persisting to database
- Import from external sources
- User privacy settings (opt-in URL cleaning)

**❌ Don't Use For:**
- App Store share links (unless whitelisting `pt`, `ct`, `mt`)
- Internal app URLs with intentional tracking
- URLs you explicitly constructed with specific parameters

## Performance

URLCleanser is designed for efficiency:
- **Single URL**: < 1ms
- **100 URLs**: < 50ms
- **Memory**: < 1MB overhead
- **Zero allocations** for clean URLs (early exit optimization)

## Testing

The package includes 75+ comprehensive tests covering:
- All tracking parameter categories
- Whitelist preservation
- Edge cases (fragments, encoding, special characters)
- Performance benchmarks
- Real-world integration scenarios

Run tests:
```bash
swift test
```

## Requirements

- iOS 16.0+ / macOS 13.0+
- Swift 5.9+
- Xcode 15.0+

## License

URLCleanser is released under the MIT License. See [LICENSE](LICENSE) for details.

## Contributing

Contributions are welcome! If you discover new tracking parameters or patterns, please open an issue or submit a pull request.

## Author

Nicolo Stanciu ([@NickAtGit](https://github.com/NickAtGit))

## Projects Using URLCleanser

- **[NFC.cool](https://nfc.cool)** - Read & write NFC tags
- **[NFC.cool Business Card Maker](https://mycard.nfc.cool)** - Digital business card platform using URLCleanser for privacy-conscious URL handling

_Using URLCleanser in your project? Open a PR to add it here!_

---

**Privacy by Design** - URLCleanser helps you build privacy-conscious apps by removing third-party tracking while preserving your app's internal analytics needs.
