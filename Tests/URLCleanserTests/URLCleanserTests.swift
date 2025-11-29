import XCTest
@testable import URLCleanser

final class URLCleanserTests: XCTestCase {

    // MARK: - UTM Parameter Tests

    func testRemovesUTMSource() {
        let url = URL(string: "https://example.com?utm_source=facebook&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    func testRemovesAllUTMParameters() {
        let url = URL(string: "https://example.com?utm_source=fb&utm_medium=social&utm_campaign=spring2024&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    func testRemovesExtendedUTMParameters() {
        let url = URL(string: "https://example.com?utm_id=abc&utm_source_platform=instagram&utm_creative_format=video&product=widget")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?product=widget")
    }

    // MARK: - Social Media Tracking Tests

    func testRemovesFacebookTracking() {
        let url = URL(string: "https://example.com?fbclid=IwAR123&id=456")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=456")
    }

    func testRemovesGoogleClickID() {
        let url = URL(string: "https://example.com?gclid=abc123&product=test")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?product=test")
    }

    func testRemovesMicrosoftClickID() {
        let url = URL(string: "https://example.com?msclkid=xyz789&page=home")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?page=home")
    }

    func testRemovesTwitterTracking() {
        let url = URL(string: "https://example.com?twclid=abc&tw_source=share&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    func testRemovesLinkedInTracking() {
        let url = URL(string: "https://example.com?li_fat_id=abc&lipi=xyz&name=test")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?name=test")
    }

    // MARK: - Email Marketing Tests

    func testRemovesMailchimpTracking() {
        let url = URL(string: "https://example.com?mc_cid=campaign123&mc_eid=email456&id=789")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=789")
    }

    func testRemovesHubSpotTracking() {
        let url = URL(string: "https://example.com?_hsenc=abc&_hsmi=123&__hssc=xyz&article=test")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?article=test")
    }

    // MARK: - Analytics Tests

    func testRemovesGoogleAnalyticsCookies() {
        let url = URL(string: "https://example.com?_ga=abc&_gid=xyz&page=home")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?page=home")
    }

    func testRemovesAdobeTracking() {
        let url = URL(string: "https://example.com?s_cid=campaign&adobe_mc=tracking&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    // MARK: - Affiliate Tracking Tests

    func testRemovesAmazonTracking() {
        let url = URL(string: "https://example.com?tag=affiliate-20&ascsubtag=abc&product=book")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?product=book")
    }

    func testRemovesEbayTracking() {
        let url = URL(string: "https://example.com?mkcid=1&mkevt=2&mkrid=3&item=test")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?item=test")
    }

    // MARK: - Multiple Tracking Parameters

    func testRemovesMultipleMixedTrackingParameters() {
        let url = URL(string: "https://example.com?utm_source=fb&fbclid=abc&mc_cid=123&gclid=xyz&id=456&name=test")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=456&name=test")
    }

    // MARK: - Preserving Non-Tracking Parameters

    func testPreservesNonTrackingParameters() {
        let url = URL(string: "https://example.com?id=123&name=test&page=home&utm_source=fb")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123&name=test&page=home")
    }

    func testPreservesParameterOrder() {
        let url = URL(string: "https://example.com?first=1&utm_source=fb&second=2&gclid=abc&third=3")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?first=1&second=2&third=3")
    }

    // MARK: - URLs Without Query Strings

    func testURLWithoutQueryString() {
        let url = URL(string: "https://example.com/path")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com/path")
    }

    func testURLWithOnlyTrackingParameters() {
        let url = URL(string: "https://example.com?utm_source=fb&gclid=abc&fbclid=xyz")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com")
    }

    // MARK: - Checking for Tracking Parameters

    func testContainsTrackingParametersReturnsTrue() {
        let url = URL(string: "https://example.com?utm_source=fb&id=123")!
        XCTAssertTrue(url.containsTrackingParameters())
    }

    func testContainsTrackingParametersReturnsFalse() {
        let url = URL(string: "https://example.com?id=123&name=test")!
        XCTAssertFalse(url.containsTrackingParameters())
    }

    func testContainsTrackingParametersWithNoQueryString() {
        let url = URL(string: "https://example.com")!
        XCTAssertFalse(url.containsTrackingParameters())
    }

    // MARK: - Getting Tracking Parameters

    func testTrackingParametersReturnsCorrectDictionary() {
        let url = URL(string: "https://example.com?utm_source=fb&utm_medium=social&id=123")!
        let tracking = url.trackingParameters()
        XCTAssertEqual(tracking.count, 2)
        XCTAssertEqual(tracking["utm_source"] as? String, "fb")
        XCTAssertEqual(tracking["utm_medium"] as? String, "social")
    }

    func testTrackingParametersReturnsEmptyForCleanURL() {
        let url = URL(string: "https://example.com?id=123&name=test")!
        let tracking = url.trackingParameters()
        XCTAssertTrue(tracking.isEmpty)
    }

    // MARK: - Pattern Matching Tests

    func testPatternMatchingUTMPrefix() {
        let url = URL(string: "https://example.com?utm_custom_field=value&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    func testPatternMatchingFacebookPrefix() {
        let url = URL(string: "https://example.com?fb_custom=value&name=test")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?name=test")
    }

    func testPatternMatchingTrackingPrefix() {
        let url = URL(string: "https://example.com?tracking_id=abc&track_source=xyz&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    // MARK: - Case Sensitivity Tests

    func testCaseInsensitiveParameterMatching() {
        let url = URL(string: "https://example.com?UTM_SOURCE=fb&FbClId=abc&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    // MARK: - Mutating Variant Tests

    func testMutatingRemoveTrackingParameters() {
        var url = URL(string: "https://example.com?utm_source=fb&id=123")!
        url.removeTrackingParameters()
        XCTAssertEqual(url.absoluteString, "https://example.com?id=123")
    }
}
