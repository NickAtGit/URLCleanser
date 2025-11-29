import Foundation

/// Comprehensive database of tracking parameters organized by category
public struct TrackingParameter {

    // MARK: - UTM Parameters (9 parameters)

    /// Standard and extended UTM tracking parameters used by Google Analytics and other platforms
    public static let utm: Set<String> = [
        "utm_source",
        "utm_medium",
        "utm_campaign",
        "utm_term",
        "utm_content",
        "utm_id",
        "utm_source_platform",
        "utm_creative_format",
        "utm_marketing_tactic",
    ]

    // MARK: - Social Media Trackers (25+ parameters)

    /// Tracking parameters used by social media platforms
    public static let socialMedia: Set<String> = [
        // Facebook
        "fbclid",
        "fb_action_ids",
        "fb_action_types",
        "fb_source",
        "fb_ref",

        // Google
        "gclid",
        "gclsrc",
        "dclid",
        "gbraid",
        "wbraid",

        // Microsoft
        "msclkid",
        "msclid",

        // Twitter/X
        "twclid",
        "tw_source",
        "tw_campaign",

        // LinkedIn
        "li_fat_id",
        "lipi",
        "licu",

        // TikTok
        "ttclid",
        "tt_medium",
        "tt_content",

        // Instagram
        "igshid",
        "ig_rid",

        // Pinterest
        "epik",

        // Snapchat
        "sccid",

        // Reddit
        "rdt_cid",
    ]

    // MARK: - Email Marketing (15+ parameters)

    /// Tracking parameters used by email marketing platforms
    public static let emailMarketing: Set<String> = [
        // Mailchimp
        "mc_cid",
        "mc_eid",

        // HubSpot
        "_hsenc",
        "_hsmi",
        "__hssc",
        "__hstc",
        "__hsfp",

        // SendGrid
        "sg_link_id",

        // Campaign Monitor
        "cm_mmc",

        // ActiveCampaign
        "vgo_ee",

        // Marketo
        "mkt_tok",

        // Constant Contact
        "cc_cid",

        // GetResponse
        "gr_cid",

        // AWeber
        "aweber",
    ]

    // MARK: - Analytics & Tracking (30+ parameters)

    /// Tracking parameters used by analytics platforms
    public static let analytics: Set<String> = [
        // Adobe
        "s_cid",
        "adobe_mc",

        // Mixpanel
        "mp_source",
        "mp_medium",
        "mp_campaign",

        // Amplitude
        "amp_source",
        "amp_medium",
        "amp_campaign",

        // Segment
        "seg_source",
        "seg_medium",
        "seg_campaign",

        // Matomo/Piwik
        "mtm_source",
        "mtm_medium",
        "mtm_campaign",
        "pk_source",
        "pk_medium",
        "pk_campaign",

        // Yandex
        "yclid",
        "_openstat",

        // Google Analytics
        "_ga",
        "_gid",
        "_gl",

        // Omniture
        "icid",

        // Criteo
        "criteo",

        // Taboola
        "tblci",

        // Outbrain
        "obOrigUrl",

        // Branch.io
        "branch_match_id",

        // Adjust
        "adjust_tracker",
        "adjust_campaign",
    ]

    // MARK: - Affiliate & E-commerce (25+ parameters)

    /// Tracking parameters used by affiliate networks and e-commerce platforms
    public static let affiliate: Set<String> = [
        // Amazon
        "tag",
        "ascsubtag",
        "asc_campaign",
        "asc_source",
        "asc_refurl",

        // eBay
        "mkcid",
        "mkevt",
        "mkrid",
        "campid",
        "toolid",

        // Rakuten
        "ranMID",
        "ranEAID",
        "ranSiteID",

        // ShareASale
        "sscid",
        "ssubtag",

        // Impact
        "irclickid",
        "irgwc",

        // CJ Affiliate (Commission Junction)
        "cjid",
        "cjdata",

        // Awin
        "awc",
        "awinmid",

        // Skimlinks
        "skimlinks",

        // VigLink
        "vglink",

        // Apple App Store Attribution
        "pt",
        "ct",
        "mt",
    ]

    // MARK: - General Tracking (15+ parameters)

    /// General tracking parameters used across various platforms
    public static let general: Set<String> = [
        "ref",
        "referer",
        "referrer",
        "source",
        "campaign",
        "medium",
        "wickedid",
        "vero_id",
        "trk",
        "trkid",
        "_hsenc",
        "mkt_tok",
        "hmb_campaign",
        "hmb_medium",
        "hmb_source",
    ]

    // MARK: - All Known Parameters

    /// Combined set of all known tracking parameters (100+ parameters)
    public static let allKnown: Set<String> = {
        var params = Set<String>()
        params.formUnion(utm)
        params.formUnion(socialMedia)
        params.formUnion(emailMarketing)
        params.formUnion(analytics)
        params.formUnion(affiliate)
        params.formUnion(general)
        return params
    }()

    // MARK: - Pattern-Based Detection

    /// Regular expression patterns for detecting unknown tracking parameters
    private static let trackingPatterns: [NSRegularExpression] = {
        let patterns = [
            "^utm_",
            "^fb_",
            "^track(ing)?_",
            "^analytics?_",
            "^mc_",
            "^ga_",
            "^_ga",
            "^gclid",
            "^fbclid",
        ]

        return patterns.compactMap { pattern in
            try? NSRegularExpression(pattern: pattern, options: .caseInsensitive)
        }
    }()

    /// Checks if a parameter name matches known tracking patterns
    /// - Parameter name: The query parameter name to check
    /// - Returns: True if the parameter matches a tracking pattern
    public static func matchesTrackingPattern(_ name: String) -> Bool {
        let range = NSRange(location: 0, length: name.utf16.count)
        return trackingPatterns.contains { pattern in
            pattern.firstMatch(in: name, options: [], range: range) != nil
        }
    }

    /// Checks if a parameter is a known tracking parameter or matches a tracking pattern
    /// - Parameter name: The query parameter name to check
    /// - Returns: True if the parameter is a tracking parameter
    public static func isTrackingParameter(_ name: String) -> Bool {
        let lowercasedName = name.lowercased()
        return allKnown.contains(lowercasedName) || matchesTrackingPattern(lowercasedName)
    }
}
