import Foundation

/// Categories of tracking parameters for organization and classification
public enum TrackingParameterCategory: String, CaseIterable {
    case utm = "UTM Parameters"
    case socialMedia = "Social Media"
    case emailMarketing = "Email Marketing"
    case analytics = "Analytics"
    case affiliate = "Affiliate & E-commerce"
    case general = "General Tracking"
}
