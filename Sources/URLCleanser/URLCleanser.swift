import Foundation

public extension URL {

    // MARK: - Removing Tracking Parameters

    /// Removes tracking parameters from the URL while preserving whitelisted parameters.
    ///
    /// This method removes common tracking parameters used by analytics platforms, social media,
    /// email marketing tools, and affiliate networks. It preserves the URL structure and all
    /// non-tracking query parameters.
    ///
    /// - Parameter whitelist: An optional set of parameter names to preserve, even if they
    ///                        match tracking parameter patterns. Use this to preserve internal
    ///                        tracking parameters like `source`, `pt`, `ct`, or `mt`.
    ///
    /// - Returns: A new URL with tracking parameters removed. Returns the original URL if:
    ///            - The URL has no query parameters
    ///            - No tracking parameters were found
    ///            - The URL cannot be parsed
    ///
    /// - Example:
    ///   ```swift
    ///   let url = URL(string: "https://example.com?utm_source=fb&id=123")!
    ///   let clean = url.removingTrackingParameters()
    ///   // Result: https://example.com?id=123
    ///   ```
    ///
    /// - Note: This method is non-mutating. Use `removeTrackingParameters(preserving:)` for
    ///         in-place mutation.
    func removingTrackingParameters(preserving whitelist: Set<String>? = nil) -> URL {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return self
        }

        guard let queryItems = components.queryItems, !queryItems.isEmpty else {
            return self
        }

        let cleanedItems = queryItems.filter { item in
            // Preserve whitelisted parameters
            if let whitelist = whitelist, whitelist.contains(item.name) {
                return true
            }

            // Remove known tracking parameters
            if TrackingParameter.allKnown.contains(item.name.lowercased()) {
                return false
            }

            // Remove pattern-matched tracking parameters
            if TrackingParameter.matchesTrackingPattern(item.name) {
                return false
            }

            return true
        }

        // If all parameters removed, set to nil instead of empty array
        components.queryItems = cleanedItems.isEmpty ? nil : cleanedItems

        return components.url ?? self
    }

    /// In-place mutation variant that removes tracking parameters from the URL.
    ///
    /// This method modifies the URL in place for performance-critical scenarios where you
    /// need to process many URLs.
    ///
    /// - Parameter whitelist: An optional set of parameter names to preserve.
    ///
    /// - Example:
    ///   ```swift
    ///   var urls = [URL]()
    ///   for i in urls.indices {
    ///       urls[i].removeTrackingParameters()
    ///   }
    ///   ```
    mutating func removeTrackingParameters(preserving whitelist: Set<String>? = nil) {
        self = removingTrackingParameters(preserving: whitelist)
    }

    // MARK: - Checking for Tracking Parameters

    /// Checks if the URL contains any tracking parameters.
    ///
    /// - Parameter whitelist: An optional set of parameter names to ignore when checking.
    ///                        These parameters won't be considered as tracking parameters
    ///                        even if they match tracking patterns.
    ///
    /// - Returns: True if the URL contains at least one tracking parameter that is not
    ///            in the whitelist, false otherwise.
    ///
    /// - Example:
    ///   ```swift
    ///   let url = URL(string: "https://example.com?utm_source=fb")!
    ///   if url.containsTrackingParameters() {
    ///       print("URL contains tracking")
    ///   }
    ///   ```
    func containsTrackingParameters(ignoring whitelist: Set<String>? = nil) -> Bool {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems, !queryItems.isEmpty else {
            return false
        }

        return queryItems.contains { item in
            // Ignore whitelisted parameters
            if let whitelist = whitelist, whitelist.contains(item.name) {
                return false
            }

            // Check if it's a known tracking parameter or matches a pattern
            return TrackingParameter.isTrackingParameter(item.name)
        }
    }

    // MARK: - Getting Tracking Parameters

    /// Returns all tracking parameters found in the URL.
    ///
    /// - Parameter whitelist: An optional set of parameter names to ignore when collecting
    ///                        tracking parameters.
    ///
    /// - Returns: A dictionary of tracking parameter names to their values. If a parameter
    ///            has no value, the value will be `nil` in the dictionary.
    ///
    /// - Example:
    ///   ```swift
    ///   let url = URL(string: "https://example.com?utm_source=fb&utm_medium=social&id=123")!
    ///   let tracking = url.trackingParameters()
    ///   // Result: ["utm_source": "fb", "utm_medium": "social"]
    ///   ```
    func trackingParameters(ignoring whitelist: Set<String>? = nil) -> [String: String?] {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems, !queryItems.isEmpty else {
            return [:]
        }

        var trackingParams: [String: String?] = [:]

        for item in queryItems {
            // Skip whitelisted parameters
            if let whitelist = whitelist, whitelist.contains(item.name) {
                continue
            }

            // Collect tracking parameters
            if TrackingParameter.isTrackingParameter(item.name) {
                trackingParams[item.name] = item.value
            }
        }

        return trackingParams
    }
}
