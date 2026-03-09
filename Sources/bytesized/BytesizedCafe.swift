import Foundation
import Plot

enum BytesizedCafePageType: String {
    case archive
    case article
    case index
}

struct BytesizedCafeConfiguration {
    let functionURL: String

    static var current: Self? {
        guard
            let functionURL = ProcessInfo.processInfo.environment["BYTESIZED_CAFE_FUNCTION_URL"]?
                .trimmingCharacters(in: .whitespacesAndNewlines),
            !functionURL.isEmpty
        else {
            return nil
        }

        return Self(functionURL: functionURL)
    }
}

extension Node where Context == HTML.AnchorContext {
    static func bytesizedCafeMount(
        pagePath: String,
        pageType: BytesizedCafePageType,
        configuration: BytesizedCafeConfiguration?
    ) -> Node {
        .div(
            .id("bytesized-cafe-app"),
            .class("bytesized-cafe-app"),
            .attribute(named: "data-function-url", value: configuration?.functionURL ?? ""),
            .attribute(named: "data-page-path", value: pagePath),
            .attribute(named: "data-page-type", value: pageType.rawValue),
            .attribute(named: "data-state", value: "idle"),
            .img(
                .class("bytesized-cafe-image"),
                .src("/images/preparing.png"),
                .alt("Finding something local..."),
                .attribute(named: "width", value: "160"),
                .attribute(named: "height", value: "160")
            )
        )
    }
}

extension Node where Context == HTML.BodyContext {
    static var bytesizedCafeScripts: Node {
        guard BytesizedCafeConfiguration.current != nil else {
            return .empty
        }

        return .script(
            .attribute(named: "type", value: "module"),
            .raw(
                """
                import { init } from "/bytesized-cafe-app/index.js";

                void init();
                """
            )
        )
    }
}
