import Foundation
import JavaScriptEventLoop

@main
struct App {
    static func main() {
        if #available(macOS 14.0, *) {
            JavaScriptEventLoop.installGlobalExecutor()
        }

        Task {
            await BytesizedCafe.start()
        }
    }
}
