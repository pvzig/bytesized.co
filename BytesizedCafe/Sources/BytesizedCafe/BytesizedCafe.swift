import Foundation
import JavaScriptKit
import Parcel

struct BytesizedCafe {
    enum ObjectKeys: String {
        case started
        case state
    }

    enum StorageKeys: String {
        case imageURL = "bytesized-cafe-image-url"
        case pagePath = "bytesized-cafe-page-path"
        case pageType = "bytesized-cafe-page-type"
    }

    private static var client: Client {
        #if arch(wasm32)
            Client()
        #else
            fatalError("BytesizedCafe only supports Parcel's browser client on wasm32 builds")
        #endif
    }

    static func start() {
        guard
            let root = mount(),
            let configuration = Config(root: root),
            root.dataset.object?[ObjectKeys.started.rawValue].string
                == PreparationState.ordered.rawValue
        else {
            return
        }

        if let cachedImageURL = cachedImageURL(for: configuration) {
            applyImage(cachedImageURL, root: root)
            updateState(.ready, root: root)
            return
        }

        updateState(.preparing, root: root)

        Task {
            do {
                let generatedImage = try await requestImage(for: configuration)
                cacheImageURL(generatedImage.url, for: configuration)
                applyImage(generatedImage.url, root: root)
                updateState(.ready, root: root)
            } catch {
                updateState(.ordered, root: root)
            }
        }
    }

    private static func mount() -> JSObject? {
        JSObject.global.document.getElementById("bytesized-cafe-app").object
    }

    private static func requestImage(for configuration: Config) async throws
        -> GenerateImageResponse
    {
        try await client.send(
            .post(
                configuration.apiURL,
                body: GenerateImageRequest(context: configuration.pageContext)
            ),
            as: GenerateImageResponse.self
        ).value
    }

    private static func cachedImageURL(for configuration: Config) -> URL? {
        guard
            isReloadNavigation(),
            let sessionStorage,
            sessionStorage.getItem?(StorageKeys.pagePath.rawValue).string
                == configuration.pageContext.pagePath,
            sessionStorage.getItem?(StorageKeys.pageType.rawValue).string
                == configuration.pageContext.pageType,
            let imageURLString = sessionStorage.getItem?(StorageKeys.imageURL.rawValue).string
        else {
            return nil
        }

        return URL(string: imageURLString)
    }

    private static func cacheImageURL(_ url: URL, for configuration: Config) {
        guard let sessionStorage else {
            return
        }

        _ = sessionStorage.setItem?(
            StorageKeys.pagePath.rawValue, configuration.pageContext.pagePath)
        _ = sessionStorage.setItem?(
            StorageKeys.pageType.rawValue, configuration.pageContext.pageType)
        _ = sessionStorage.setItem?(StorageKeys.imageURL.rawValue, url.absoluteString)
    }

    private static func applyImage(_ url: URL, root: JSObject) {
        guard
            let image = root.querySelector?(".bytesized-cafe-image").object
        else {
            return
        }

        image["src"] = JSValue.string(url.absoluteString)
        image["alt"] = JSValue.string(
            "👨🏻‍🍳🍲😋")
    }

    private static func updateState(_ state: PreparationState, root: JSObject) {
        root.dataset.object?[ObjectKeys.started.rawValue] = JSValue.string(state.rawValue)
        root.dataset.object?[ObjectKeys.state.rawValue] = JSValue.string(state.rawValue)
    }

    private static var sessionStorage: JSObject? {
        JSObject.global.sessionStorage.object
    }

    private static func isReloadNavigation() -> Bool {
        guard let performance = JSObject.global.performance.object else {
            return false
        }

        if let navigationEntry = performance.getEntriesByType?("navigation")[0].object,
            navigationEntry["type"].string == "reload"
        {
            return true
        }

        if let navigationType = performance["navigation"].object?["type"].number {
            return navigationType == 1
        }

        return false
    }
}
