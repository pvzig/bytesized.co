import Foundation
import JavaScriptEventLoop

@main
struct App {
    static func main() {
        #if arch(wasm32)
            JavaScriptEventLoop.installGlobalExecutor()
            BytesizedCafe.start()
        #endif
    }
}
