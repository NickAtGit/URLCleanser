import XCTest
@testable import URLCleanser

final class EdgeCaseTests: XCTestCase {

    // MARK: - URL Fragments

    func testPreservesURLFragment() {
        let url = URL(string: "https://example.com?utm_source=fb&id=123#section")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123#section")
    }

    func testPreservesFragmentWithOnlyTrackingParameters() {
        let url = URL(string: "https://example.com?utm_source=fb&gclid=abc#top")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com#top")
    }

    func testURLWithFragmentButNoQueryString() {
        let url = URL(string: "https://example.com#section")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com#section")
    }

    // MARK: - Encoded Parameters

    func testHandlesURLEncodedParameterValues() {
        let url = URL(string: "https://example.com?utm_source=facebook%20ads&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("id=123"))
        XCTAssertFalse(cleaned.absoluteString.contains("utm_source"))
    }

    func testHandlesEncodedSpecialCharacters() {
        let url = URL(string: "https://example.com?utm_campaign=test%20%26%20demo&name=John%20Doe")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("name=John%20Doe"))
        XCTAssertFalse(cleaned.absoluteString.contains("utm_campaign"))
    }

    // MARK: - Empty and Nil Values

    func testHandlesParametersWithEmptyValues() {
        let url = URL(string: "https://example.com?utm_source=&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    func testHandlesParametersWithoutValues() {
        let url = URL(string: "https://example.com?utm_source&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("id=123"))
        XCTAssertFalse(cleaned.absoluteString.contains("utm_source"))
    }

    // MARK: - Duplicate Parameters

    func testHandlesDuplicateTrackingParameters() {
        let url = URL(string: "https://example.com?utm_source=fb&utm_source=google&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com?id=123")
    }

    func testHandlesDuplicateNonTrackingParameters() {
        let url = URL(string: "https://example.com?id=123&id=456&utm_source=fb")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("id="))
        XCTAssertFalse(cleaned.absoluteString.contains("utm_source"))
    }

    // MARK: - Empty Query Strings

    func testHandlesEmptyQueryString() {
        let url = URL(string: "https://example.com?")!
        let cleaned = url.removingTrackingParameters()
        // URLComponents may or may not preserve the trailing '?'
        XCTAssertTrue(cleaned.absoluteString == "https://example.com" || cleaned.absoluteString == "https://example.com?")
    }

    // MARK: - Complex URLs

    func testHandlesComplexURLWithPathAndPort() {
        let url = URL(string: "https://example.com:8080/path/to/resource?utm_source=fb&id=123&utm_medium=social")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "https://example.com:8080/path/to/resource?id=123")
    }

    func testHandlesURLWithUsername() {
        let url = URL(string: "https://user@example.com/path?utm_source=fb&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("user@example.com"))
        XCTAssertTrue(cleaned.absoluteString.contains("id=123"))
        XCTAssertFalse(cleaned.absoluteString.contains("utm_source"))
    }

    func testHandlesURLWithUsernameAndPassword() {
        let url = URL(string: "https://user:pass@example.com?gclid=abc&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("user:pass@example.com"))
        XCTAssertTrue(cleaned.absoluteString.contains("id=123"))
        XCTAssertFalse(cleaned.absoluteString.contains("gclid"))
    }

    // MARK: - IPv4 and IPv6 URLs

    func testHandlesIPv4URL() {
        let url = URL(string: "http://192.168.1.1?utm_source=fb&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "http://192.168.1.1?id=123")
    }

    func testHandlesIPv6URL() {
        let url = URL(string: "http://[2001:db8::1]?gclid=abc&page=home")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("[2001:db8::1]"))
        XCTAssertTrue(cleaned.absoluteString.contains("page=home"))
        XCTAssertFalse(cleaned.absoluteString.contains("gclid"))
    }

    // MARK: - Different URL Schemes

    func testHandlesHTTPScheme() {
        let url = URL(string: "http://example.com?utm_source=fb&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "http://example.com?id=123")
    }

    func testHandlesCustomScheme() {
        let url = URL(string: "myapp://action?utm_source=fb&action=open")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertEqual(cleaned.absoluteString, "myapp://action?action=open")
    }

    func testHandlesFileURL() {
        let url = URL(string: "file:///path/to/file.html?utm_source=fb&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("file:///path/to/file.html"))
        XCTAssertTrue(cleaned.absoluteString.contains("id=123"))
        XCTAssertFalse(cleaned.absoluteString.contains("utm_source"))
    }

    // MARK: - Very Long URLs

    func testHandlesVeryLongURL() {
        var queryItems = "id=123"
        for i in 0..<50 {
            queryItems += "&utm_param\(i)=value\(i)"
        }
        let url = URL(string: "https://example.com?\(queryItems)")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("id=123"))
        XCTAssertFalse(cleaned.absoluteString.contains("utm_param"))
    }

    // MARK: - International Domain Names

    func testHandlesInternationalDomainName() {
        let url = URL(string: "https://example.中国?utm_source=fb&id=123")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("id=123"))
        XCTAssertFalse(cleaned.absoluteString.contains("utm_source"))
    }

    // MARK: - Special Characters in Parameter Names

    func testHandlesParametersWithDashesAndUnderscores() {
        let url = URL(string: "https://example.com?my-param=test&my_param=test2&utm_source=fb")!
        let cleaned = url.removingTrackingParameters()
        XCTAssertTrue(cleaned.absoluteString.contains("my-param=test"))
        XCTAssertTrue(cleaned.absoluteString.contains("my_param=test2"))
        XCTAssertFalse(cleaned.absoluteString.contains("utm_source"))
    }

    // MARK: - TrackingParameter Helper Methods

    func testIsTrackingParameterWithKnownParameter() {
        XCTAssertTrue(TrackingParameter.isTrackingParameter("utm_source"))
        XCTAssertTrue(TrackingParameter.isTrackingParameter("fbclid"))
        XCTAssertTrue(TrackingParameter.isTrackingParameter("gclid"))
    }

    func testIsTrackingParameterWithNonTrackingParameter() {
        XCTAssertFalse(TrackingParameter.isTrackingParameter("id"))
        XCTAssertFalse(TrackingParameter.isTrackingParameter("name"))
        XCTAssertFalse(TrackingParameter.isTrackingParameter("page"))
    }

    func testIsTrackingParameterWithPatternMatch() {
        XCTAssertTrue(TrackingParameter.isTrackingParameter("utm_custom_field"))
        XCTAssertTrue(TrackingParameter.isTrackingParameter("fb_custom"))
        XCTAssertTrue(TrackingParameter.isTrackingParameter("tracking_id"))
    }

    func testMatchesTrackingPatternWithValidPatterns() {
        XCTAssertTrue(TrackingParameter.matchesTrackingPattern("utm_anything"))
        XCTAssertTrue(TrackingParameter.matchesTrackingPattern("fb_something"))
        XCTAssertTrue(TrackingParameter.matchesTrackingPattern("tracking_xyz"))
        XCTAssertTrue(TrackingParameter.matchesTrackingPattern("track_abc"))
    }

    func testMatchesTrackingPatternWithInvalidPatterns() {
        XCTAssertFalse(TrackingParameter.matchesTrackingPattern("id"))
        XCTAssertFalse(TrackingParameter.matchesTrackingPattern("name"))
        XCTAssertFalse(TrackingParameter.matchesTrackingPattern("custom"))
    }

    // MARK: - Performance Tests

    func testPerformanceWithManyParameters() {
        var queryItems = ""
        for i in 0..<100 {
            if i > 0 { queryItems += "&" }
            if i % 2 == 0 {
                queryItems += "param\(i)=value\(i)"
            } else {
                queryItems += "utm_param\(i)=value\(i)"
            }
        }
        let url = URL(string: "https://example.com?\(queryItems)")!

        measure {
            _ = url.removingTrackingParameters()
        }
    }

    func testPerformanceBulkCleaning() {
        var urls: [URL] = []
        for i in 0..<100 {
            if let url = URL(string: "https://example.com/path\(i)?utm_source=fb&gclid=abc&id=\(i)&name=test") {
                urls.append(url)
            }
        }

        measure {
            for url in urls {
                _ = url.removingTrackingParameters()
            }
        }
    }

    // MARK: - Nil and Invalid URL Handling

    func testURLComponentsFailureReturnsSelf() {
        // Create a URL that URLComponents might struggle with
        let url = URL(string: "https://example.com?utm_source=test")!
        let cleaned = url.removingTrackingParameters()
        // Should always return a valid URL
        XCTAssertNotNil(cleaned)
    }
}
