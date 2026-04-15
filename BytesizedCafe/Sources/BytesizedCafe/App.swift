import Foundation
import JavaScriptEventLoop

@main
struct App {
    static func main() {
        JavaScriptEventLoop.installGlobalExecutor()
        BytesizedCafe.start()
    }
}
