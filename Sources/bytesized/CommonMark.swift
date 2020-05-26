
import Foundation
import Publish
import CommonMark

extension Item {
    var commonMarkBody: String {
        let item = self as! Item<Bytesized>
        let stripped = item.content.body.html.stripMetadata()
        let cmark = try! Document(stripped)
        let html = cmark.render(format: .html, options: .unsafe)
        return footnotes(html: html, date: item.metadata.date)
    }
}
