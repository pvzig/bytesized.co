import Foundation
import Publish
import Plot

struct Bytesized: Website {
    enum SectionID: String, WebsiteSectionID {
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        var date: Date
        var title: String
        var permalink: String
    }

    var url = URL(string: "https://bytesized.co")!
    var name = "bytesized"
    var language: Language { .english }
    var imagePath: Path? { nil }
    var description: String { "by Peter Zignego" }
}

try Bytesized().publish(using: [
    .step(named: "Custom Date Formatter") { context in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        context.dateFormatter = formatter
    },
    .copyResources(),
    .addMarkdownFiles(rawContent: true),
    .sortItems(by: \.metadata.date, order: .descending),
    .step(named: "Paginate") { context in
        for section in context.sections.ids {
            let chunks = context.sections[section].items.chunked(into: 5)
            for (i, chunk) in chunks.enumerated() {
                // Index
                if i == 0 {
                    continue
                }
                let page = Page(path: "\(i)", content: context.pageContent(for: i, items: chunk))
                context.addPage(page)
            }
        }
    },
    .generateHTML(withTheme: .bytesized, fileMode: .standAloneFiles)
])

public extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
