
import Foundation

extension String {
    func stripMetadata() -> String {
        do {
            let metadata = try NSRegularExpression(pattern: #"---([\s\S]*?)---"#, options: [])
            let match = metadata.firstMatch(in: self, options: [], range: NSRange(location: 0, length: utf16.count))
            if let range = match?.range {
                let substring = NSString(string: self).substring(with: range)
                return self.replacingOccurrences(of: substring, with: "")
            } else {
                return self
            }
        } catch _ {
            return self
        }
    }
}
