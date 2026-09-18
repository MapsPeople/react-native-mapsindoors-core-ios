//
//  DirectionsRendererOptions.swift
//  react-native-maps-indoors
//

import Foundation
import MapsIndoors
import UIKit

/// The flat directions renderer options as they cross the React Native bridge.
///
/// Mirrors ``MPDirectionsRendererOptions``, with colors as hex strings, icons as URL strings and
/// enums as their raw wire values. Every field is optional, so an option the app left out stays
/// `nil` and is inherited from the solution config, or from the SDK's built-in default.
struct DirectionsRendererOptions: Codable {
    var strokeColor: String?
    var strokeOpacity: Double?
    var strokeWeight: Double?
    var strokeStyle: String?
    var backgroundColorEnabled: Bool?
    var backgroundColor: String?
    var backgroundColorOpacity: Double?
    var backgroundColorWeight: Double?
    var animationType: String?
    var animationSpeed: Double?
    var animationMinDuration: Double?
    var animationRepeating: Bool?
    var forceAnimation: Bool?
    var animatedOverlayColor: String?
    var animatedOverlayOpacity: Double?
    var animatedOverlayWeight: Double?
    var stampType: String?
    var stampImageUrl: String?
    var stampSpacing: Double?
    var stampScale: Double?
    var arrowStyle: String?
    var stampColor: String?
    var startDisplayRule: RouteMarkerDisplayRule?
    var endDisplayRule: RouteMarkerDisplayRule?
    var legBoundaryIcons: LegBoundaryIcons?
    var elevated: Bool?
    var elevationHeight: Double?
    var fitBoundsMaxZoom: Double?

    /// The styling of a route's origin or destination marker.
    struct RouteMarkerDisplayRule: Codable {
        var iconUrl: String?
        var iconVisible: Bool?
        var iconSize: IconSize?
        var label: String?
        var labelVisible: Bool?
        var labelTextSize: Double?
        var labelTextColor: String?
        var labelHaloColor: String?
        var labelHaloWidth: Double?
        var zoomFrom: Double?
        var zoomTo: Double?

        func toMPRouteMarkerDisplayRule() -> MPRouteMarkerDisplayRule {
            let rule = MPRouteMarkerDisplayRule()
            rule.iconUrl = iconUrl.flatMap { URL(string: $0) }
            rule.iconVisible = iconVisible.map { NSNumber(value: $0) }
            rule.iconSize = iconSize.flatMap { $0.toCGSize() }
            rule.label = label
            rule.labelVisible = labelVisible.map { NSNumber(value: $0) }
            rule.labelTextSize = labelTextSize.map { NSNumber(value: $0) }
            rule.labelTextColor = labelTextColor.flatMap { UIColor(hex: $0) }
            rule.labelHaloColor = labelHaloColor.flatMap { UIColor(hex: $0) }
            rule.labelHaloWidth = labelHaloWidth.map { NSNumber(value: $0) }
            rule.zoomFrom = zoomFrom.map { NSNumber(value: $0) }
            rule.zoomTo = zoomTo.map { NSNumber(value: $0) }
            return rule
        }

        init() {}

        init(from rule: MPRouteMarkerDisplayRule) {
            iconUrl = rule.iconUrl?.absoluteString
            iconVisible = rule.iconVisible?.boolValue
            iconSize = rule.iconSize.map { IconSize(from: $0) }
            label = rule.label
            labelVisible = rule.labelVisible?.boolValue
            labelTextSize = rule.labelTextSize?.doubleValue
            labelTextColor = rule.labelTextColor.flatMap { $0.hexString }
            labelHaloColor = rule.labelHaloColor.flatMap { $0.hexString }
            labelHaloWidth = rule.labelHaloWidth?.doubleValue
            zoomFrom = rule.zoomFrom?.doubleValue
            zoomTo = rule.zoomTo?.doubleValue
        }
    }

    /// Explicit icon dimensions in points.
    struct IconSize: Codable {
        var width: Double?
        var height: Double?

        /// The size, or `nil` when either dimension is missing.
        ///
        /// ``MPRouteMarkerDisplayRule/iconSize`` is a whole `CGSize`, so a half-specified size cannot
        /// be expressed. Substituting `0` for the missing half would hide the marker; leaving the whole
        /// size unset keeps it inherited, which is what an unspecified dimension means on Android too.
        func toCGSize() -> CGSize? {
            guard let width, let height else { return nil }
            return CGSize(width: width, height: height)
        }

        init(from size: CGSize) {
            width = size.width
            height = size.height
        }
    }

    /// Per connector type leg boundary icons.
    struct LegBoundaryIcons: Codable {
        var defaultIcon: String?
        var elevator: String?
        var escalator: String?
        var stairs: String?
        var ramp: String?
        var wheelchairRamp: String?
        var wheelchairLift: String?
        var ladder: String?
        var entry: String?
        var scale: Double?

        func toMPLegBoundaryIcons() -> MPLegBoundaryIcons {
            let icons = MPLegBoundaryIcons()
            icons.defaultIcon = defaultIcon.flatMap { URL(string: $0) }
            icons.elevator = elevator.flatMap { URL(string: $0) }
            icons.escalator = escalator.flatMap { URL(string: $0) }
            icons.stairs = stairs.flatMap { URL(string: $0) }
            icons.ramp = ramp.flatMap { URL(string: $0) }
            icons.wheelchairRamp = wheelchairRamp.flatMap { URL(string: $0) }
            icons.wheelchairLift = wheelchairLift.flatMap { URL(string: $0) }
            icons.ladder = ladder.flatMap { URL(string: $0) }
            icons.entry = entry.flatMap { URL(string: $0) }
            if let scale {
                icons.scale = scale
            }
            return icons
        }

        init() {}

        init(from icons: MPLegBoundaryIcons) {
            defaultIcon = icons.defaultIcon?.absoluteString
            elevator = icons.elevator?.absoluteString
            escalator = icons.escalator?.absoluteString
            stairs = icons.stairs?.absoluteString
            ramp = icons.ramp?.absoluteString
            wheelchairRamp = icons.wheelchairRamp?.absoluteString
            wheelchairLift = icons.wheelchairLift?.absoluteString
            ladder = icons.ladder?.absoluteString
            entry = icons.entry?.absoluteString
            scale = icons.scale
        }
    }

    /// Builds the SDK's options object.
    ///
    /// Every unset property is left `nil`, which is what makes an option the app omitted *inherited*
    /// rather than reset: the iOS SDK resolves each property independently as app-set -> CMS
    /// solution default -> built-in default, so assigning this whole object overrides only the
    /// properties it actually sets. The Android module has to reconstruct that resolution by hand,
    /// because its SDK merges a runtime config over the solution config whole-block.
    ///
    /// - Parameter stampImage: the already downloaded icon for a custom stamp, since
    ///   ``MPDirectionsRendererOptions/stampImage`` takes a `UIImage` rather than a URL.
    func toMPDirectionsRendererOptions(stampImage: UIImage? = nil) -> MPDirectionsRendererOptions {
        let options = MPDirectionsRendererOptions()
        options.strokeColor = strokeColor.flatMap { UIColor(hex: $0) }
        options.strokeOpacity = strokeOpacity.map { NSNumber(value: $0) }
        options.strokeWeight = strokeWeight.map { NSNumber(value: $0) }
        options.strokeStyle = strokeStyle.flatMap { DirectionsRendererOptions.strokeStyle(from: $0) }
        options.backgroundColorEnabled = backgroundColorEnabled.map { NSNumber(value: $0) }
        options.backgroundColor = backgroundColor.flatMap { UIColor(hex: $0) }
        options.backgroundColorOpacity = backgroundColorOpacity.map { NSNumber(value: $0) }
        options.backgroundColorWeight = backgroundColorWeight.map { NSNumber(value: $0) }
        options.animationType = animationType.flatMap { DirectionsRendererOptions.animationType(from: $0) }
        options.animationSpeed = animationSpeed.map { NSNumber(value: $0) }
        options.animationMinDuration = animationMinDuration.map { NSNumber(value: $0) }
        if let animationRepeating {
            options.animationRepeating = animationRepeating
        }
        options.forceAnimation = forceAnimation.map { NSNumber(value: $0) }
        options.animatedOverlayColor = animatedOverlayColor.flatMap { UIColor(hex: $0) }
        options.animatedOverlayOpacity = animatedOverlayOpacity.map { NSNumber(value: $0) }
        options.animatedOverlayWeight = animatedOverlayWeight.map { NSNumber(value: $0) }
        options.stampType = stampType.flatMap { DirectionsRendererOptions.stampType(from: $0) }
        options.stampImage = stampImage
        options.stampSpacing = stampSpacing.map { NSNumber(value: $0) }
        options.stampScale = stampScale.map { NSNumber(value: $0) }
        options.arrowStyle = arrowStyle.flatMap { DirectionsRendererOptions.arrowStyle(from: $0) }
        options.stampColor = stampColor.flatMap { UIColor(hex: $0) }
        options.startDisplayRule = startDisplayRule?.toMPRouteMarkerDisplayRule()
        options.endDisplayRule = endDisplayRule?.toMPRouteMarkerDisplayRule()
        options.legBoundaryIcons = legBoundaryIcons?.toMPLegBoundaryIcons()
        options.elevated = elevated.map { NSNumber(value: $0) }
        options.elevationHeight = elevationHeight.map { NSNumber(value: $0) }
        options.fitBoundsMaxZoom = fitBoundsMaxZoom.map { NSNumber(value: $0) }
        return options
    }

    init() {}

    /// Flattens the options the renderer currently holds back into the bridge's shape.
    ///
    /// - Parameter stampImageUrl: the URL of the custom stamp last applied through this bridge. The SDK
    ///   holds the downloaded `UIImage` rather than its URL, so it cannot be recovered from `options` -
    ///   without it a read-modify-write would feed back `stampType == .custom` with no image and silently
    ///   drop the stamp. When the URL is unknown, ``stampType`` is reported as `nil` instead, so the pair
    ///   stays self-consistent and the stamp is inherited rather than blanked.
    init(from options: MPDirectionsRendererOptions, stampImageUrl: String? = nil) {
        strokeColor = options.strokeColor.flatMap { $0.hexString }
        strokeOpacity = options.strokeOpacity?.doubleValue
        strokeWeight = options.strokeWeight?.doubleValue
        strokeStyle = options.strokeStyle.map { DirectionsRendererOptions.string(from: $0) }
        backgroundColorEnabled = options.backgroundColorEnabled?.boolValue
        backgroundColor = options.backgroundColor.flatMap { $0.hexString }
        backgroundColorOpacity = options.backgroundColorOpacity?.doubleValue
        backgroundColorWeight = options.backgroundColorWeight?.doubleValue
        animationType = options.animationType.map { DirectionsRendererOptions.string(from: $0) }
        animationSpeed = options.animationSpeed?.doubleValue
        animationMinDuration = options.animationMinDuration?.doubleValue
        animationRepeating = options.animationRepeating
        forceAnimation = options.forceAnimation?.boolValue
        animatedOverlayColor = options.animatedOverlayColor.flatMap { $0.hexString }
        animatedOverlayOpacity = options.animatedOverlayOpacity?.doubleValue
        animatedOverlayWeight = options.animatedOverlayWeight?.doubleValue
        self.stampImageUrl = stampImageUrl
        let resolvedStampType = options.stampType.map { DirectionsRendererOptions.string(from: $0) }
        stampType = resolvedStampType == "custom" && stampImageUrl == nil ? nil : resolvedStampType
        stampSpacing = options.stampSpacing?.doubleValue
        stampScale = options.stampScale?.doubleValue
        arrowStyle = options.arrowStyle.map { DirectionsRendererOptions.string(from: $0) }
        stampColor = options.stampColor.flatMap { $0.hexString }
        startDisplayRule = options.startDisplayRule.map { RouteMarkerDisplayRule(from: $0) }
        endDisplayRule = options.endDisplayRule.map { RouteMarkerDisplayRule(from: $0) }
        legBoundaryIcons = options.legBoundaryIcons.map { LegBoundaryIcons(from: $0) }
        elevated = options.elevated?.boolValue
        elevationHeight = options.elevationHeight?.doubleValue
        fitBoundsMaxZoom = options.fitBoundsMaxZoom?.doubleValue
    }

    // MARK: - Enum mapping

    private static func strokeStyle(from value: String) -> MPStrokeStyle? {
        switch value {
        case "solid": return .solid
        case "dashed": return .dashed
        case "dotted": return .dotted
        default: return nil
        }
    }

    private static func string(from value: MPStrokeStyle) -> String {
        switch value {
        case .solid: return "solid"
        case .dashed: return "dashed"
        case .dotted: return "dotted"
        @unknown default: return "solid"
        }
    }

    private static func animationType(from value: String) -> MPRouteAnimationType? {
        switch value {
        case "none": return MPRouteAnimationType.none
        case "flow": return .flow
        case "pulse": return .pulse
        case "comet": return .comet
        default: return nil
        }
    }

    private static func string(from value: MPRouteAnimationType) -> String {
        switch value {
        case .none: return "none"
        case .flow: return "flow"
        case .pulse: return "pulse"
        case .comet: return "comet"
        @unknown default: return "flow"
        }
    }

    private static func stampType(from value: String) -> MPRouteStampType? {
        switch value {
        case "none": return MPRouteStampType.none
        case "arrow": return .arrow
        case "custom": return .custom
        default: return nil
        }
    }

    private static func string(from value: MPRouteStampType) -> String {
        switch value {
        case .none: return "none"
        case .arrow: return "arrow"
        case .custom: return "custom"
        @unknown default: return "none"
        }
    }

    private static func arrowStyle(from value: String) -> MPRouteArrowStyle? {
        switch value {
        case "chevron": return .chevron
        case "chevronDouble": return .chevronDouble
        case "triangle": return .triangle
        case "arrow": return .arrow
        case "dart": return .dart
        default: return nil
        }
    }

    private static func string(from value: MPRouteArrowStyle) -> String {
        switch value {
        case .chevron: return "chevron"
        case .chevronDouble: return "chevronDouble"
        case .triangle: return "triangle"
        case .arrow: return "arrow"
        case .dart: return "dart"
        @unknown default: return "chevron"
        }
    }
}

extension UIColor {
    /// The color as an `#RRGGBB` hex string, or `nil` when it has no describable components.
    ///
    /// The bridge keeps colors opaque and carries transparency in the separate opacity options, so
    /// that a color reads back the same on both platforms - the two SDKs disagree on where the
    /// alpha component of an 8 digit hex string sits.
    var hexString: String? {
        let component = { (value: CGFloat) in Int((max(0, min(1, value)) * 255).rounded()) }

        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
        if getRed(&red, green: &green, blue: &blue, alpha: &alpha) {
            return String(format: "#%02X%02X%02X", component(red), component(green), component(blue))
        }

        // A monochrome colour has no RGB components to report, so ask for its white level and
        // describe it as the equivalent grey rather than failing.
        var white: CGFloat = 0
        if getWhite(&white, alpha: &alpha) {
            let level = component(white)
            return String(format: "#%02X%02X%02X", level, level, level)
        }

        // A pattern colour, or anything else with no numeric components: report it as absent rather
        // than inventing black, which would read back as a colour the app never set.
        return nil
    }
}
