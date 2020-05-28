
import Foundation
import Publish
import CommonMark

extension Item {
    var bytesized: Item<Bytesized> {
        return self as! Item<Bytesized>
    }
    
    var commonMarkBody: String {
        do {
            let stripped = bytesized.content.body.html.stripMetadata()
            let cmark = try Document(stripped)
            let html = cmark.render(format: .html, options: .unsafe)
            return html.parseMarkdownFootnotes(date: bytesized.metadata.date)
        } catch let error {
            fatalError("Failed to generate CommonMark body with error: \(error.localizedDescription)")
        }
    }
}
