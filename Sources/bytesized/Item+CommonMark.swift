
import Foundation
import Publish
import CommonMark

extension Item {
    var bytesized: Item<Bytesized> {
        return self as! Item<Bytesized>
    }
}

func commonMarkBody(_ content: String, metadata: Bytesized.ItemMetadata) -> String {
    do {
        let stripped = content.stripMetadata()
        let cmark = try Document(stripped)
        let html = cmark.render(format: .html, options: .unsafe)
        return html.parseMarkdownFootnotes(date: metadata.date)
    } catch let error {
        fatalError("Failed to generate CommonMark body with error: \(error.localizedDescription)")
    }
}
