import XCTest
@testable import URLCleanser

final class WhitelistTests: XCTestCase {

    // MARK: - Single Whitelist Parameter

    func testPreservesSingleWhitelistedParameter() {
        let url = URL(string: "https://example.com?source=app&utm_source=fb&id=123")!
        let cleaned = url.removingTrackingParameters(preserving: ["source"])
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?source=app&id=123")
    }

    func testPreservesWhitelistedParameterEvenIfItMatchesTrackingPattern() {
        let url = URL(string: "https://example.com?source=test&ref=home&utm_source=fb&id=123")!
        let cleaned = url.removingTrackingParameters(preserving: ["source", "ref"])
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?source=test&ref=home&id=123")
    }

    // MARK: - Multiple Whitelist Parameters

    func testPreservesMultipleWhitelistedParameters() {
        let url = URL(string: "https://example.com?source=app&ref=home&utm_source=fb&gclid=abc&id=123")!
        let cleaned = url.removingTrackingParameters(preserving: ["source", "ref", "id"])
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?source=app&ref=home&id=123")
    }

    // MARK: - NFC.cool App Integration Tests

    func testPreservesNFCCoolInternalTracking() {
        let url = URL(string: "https://nfc.cool/card?source=LiveActivity&utm_campaign=test&id=456")!
        let cleaned = url.removingTrackingParameters(preserving: ["source", "id"])
        XCTAssertEqual(cleaned.absoluteString, "https://nfc.cool/card?source=LiveActivity&id=456")
    }

    func testPreservesSourceParameterButRemovesOtherTracking() {
        let url = URL(string: "https://mycard.nfc.cool/user/name?source=LiveActivity&utm_source=facebook&utm_medium=social&fbclid=abc&gclid=xyz")!
        let cleaned = url.removingTrackingParameters(preserving: ["source"])
        XCTAssertEqual(cleaned.absoluteString, "https://mycard.nfc.cool/user/name?source=LiveActivity")
    }

    // MARK: - App Store URL Tests

    func testPreservesAppleAttributionForAppStoreLinks() {
        let url = URL(string: "https://apps.apple.com/app/id123?pt=106913804&ct=ShareApp&mt=8&utm_source=fb")!
        let cleaned = url.removingTrackingParameters(preserving: ["pt", "ct", "mt"])
        XCTAssertEqual(cleaned.absoluteString, "https://apps.apple.com/app/id123?pt=106913804&ct=ShareApp&mt=8")
    }

    func testRemovesAppleAttributionWhenNotWhitelisted() {
        let url = URL(string: "https://example.com?pt=12345&ct=campaign&product=widget&utm_source=fb")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?product=widget")
    }

    // MARK: - Contains Tracking Parameters with Whitelist

    func testContainsTrackingParametersIgnoresWhitelist() {
        let url = URL(string: "https://example.com?source=app&utm_source=fb")!
        XCTAssertTrue(url.containsTrackingParameters(ignoring: ["source"]))
    }

    func testContainsTrackingParametersReturnsFalseWhenOnlyWhitelistedTracking() {
        let url = URL(string: "https://example.com?source=app&ref=home&id=123")!
        XCTAssertFalse(url.containsTrackingParameters(ignoring: ["source", "ref"]))
    }

    // MARK: - Get Tracking Parameters with Whitelist

    func testTrackingParametersIgnoresWhitelist() {
        let url = URL(string: "https://example.com?source=app&utm_source=fb&utm_medium=social&id=123")!
        let tracking = url.trackingParameters(ignoring: ["source"])
        XCTAssertEqual(tracking.count, 2)
        XCTAssertEqual(tracking["utm_source"] as? String, "fb")
        XCTAssertEqual(tracking["utm_medium"] as? String, "social")
        XCTAssertNil(tracking["source"])
    }

    func testTrackingParametersReturnsEmptyWhenAllAreWhitelisted() {
        let url = URL(string: "https://example.com?source=app&ref=home&id=123")!
        let tracking = url.trackingParameters(ignoring: ["source", "ref"])
        XCTAssertTrue(tracking.isEmpty)
    }

    // MARK: - Empty Whitelist

    func testEmptyWhitelistBehavesLikeNoWhitelist() {
        let url = URL(string: "https://example.com?utm_source=fb&id=123")!
        let cleanedWithEmptySet = url.removingTrackingParameters(preserving: Set<String>())
        let cleanedWithoutWhitelist = url.removingTrackingParameters()
        XCTAssertEqual(cleanedWithEmptySet.absoluteString, cleanedWithoutWhitelist.absoluteString)
    }

    // MARK: - Whitelist with Non-Existent Parameters

    func testWhitelistWithNonExistentParameters() {
        let url = URL(string: "https://example.com?utm_source=fb&id=123")!
        let cleaned = url.removingTrackingParameters(preserving: ["nonexistent", "fake"])
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    // MARK: - Real-World Integration Scenarios

    func testRealWorldScenarioBusinessCardWithLiveActivity() {
        let url = URL(string: "https://mycard.nfc.cool/john/doe?source=LiveActivity&utm_source=facebook&utm_medium=cpc&utm_campaign=spring2024&fbclid=IwAR1234&gclid=xyz789")!
        let whitelist: Set<String> = ["source"]
        let cleaned = url.removingTrackingParameters(preserving: whitelist)
        XCTAssertEqual(cleaned.absoluteString, "https://mycard.nfc.cool/john/doe?source=LiveActivity")
    }

    func testRealWorldScenarioAppStoreShareLink() {
        let url = URL(string: "https://apps.apple.com/app/apple-store/id6502926572?pt=106913804&ct=ShareApp&mt=8&utm_source=email&utm_medium=newsletter")!
        let whitelist: Set<String> = ["pt", "ct", "mt"]
        let cleaned = url.removingTrackingParameters(preserving: whitelist)
        XCTAssertEqual(cleaned.absoluteString, "https://apps.apple.com/app/apple-store/id6502926572?pt=106913804&ct=ShareApp&mt=8")
    }

    func testRealWorldScenarioContactURLWithMultipleTrackers() {
        let url = URL(string: "https://example.com/contact?email=test@example.com&utm_source=linkedin&li_fat_id=abc123&mc_cid=campaign456")!
        let whitelist: Set<String> = ["email"]
        let cleaned = url.removingTrackingParameters(preserving: whitelist)
        XCTAssertEqual(cleaned.absoluteString, "https://example.com/contact?email=test@example.com")
    }

    // MARK: - Case Sensitivity in Whitelist

    func testWhitelistIsCaseSensitive() {
        let url = URL(string: "https://example.com?Source=app&source=test&utm_source=fb&id=123")!
        let cleaned = url.removingTrackingParameters(preserving: ["source"])
        // Should preserve "source" but remove "Source" if it matches tracking pattern
        // URLComponents preserves original case, so we preserve exact match
        XCTAssertTrue(cleaned.absoluteString.contains("source=test"))
    }
}
