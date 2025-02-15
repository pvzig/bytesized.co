import Foundation
import Publish
import Plot
import ShellOut

struct Bytesized: Website {
    enum SectionID: String, WebsiteSectionID {
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        var date: Date
        var title: String
        var path: String
    }

    var url = URL(string: "https://bytesized.co")!
    var name = "bytesized.co"
    var language: Language { .english }
    var imagePath: Path? { nil }
    var description: String { "a web log" }
}

extension Website {
    private var yearFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy"
        return formatter
    }
    
    var footer: String {
        let year = yearFormatter.string(from: Date())
        return "Copyright © \(year) Peter Zignego"
    }
}

try Bytesized().publish(using: [
    .step(named: "Custom Date Formatter") { context in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        context.dateFormatter = formatter
    },
    .copyResources(),
    .addMarkdownFiles(customContentParser: { text, metadata -> Content in
        Content(body: Content.Body(stringLiteral: commonMarkBody(text, metadata: metadata)))
    }),
    .step(named: "Name Index") { context in
        context.index.title = context.site.name
    },
    .mutateAllItems { item in
        item.content.title = item.metadata.title
        item.content.date = item.metadata.date
    },
    .sortItems(by: \.metadata.date, order: .descending),
    .step(named: "Paginate") { context in
        for section in context.sections.ids {
            let chunks = context.sections[section].items.chunked(into: 5)
            for (i, chunk) in chunks.enumerated() {
                // Index
                if i == 0 {
                    continue
                }
                let page = Page(path: "/page/\(i)/index.html", content: context.pageContent(for: i, items: chunk))
                context.addPage(page)
            }
        }
    },
    .generateHTML(withTheme: .bytesized, fileMode: .standAloneFilesClean),
    .generateRSSFeed(including: [.posts]),
    .deploy(using: .s3("bytesized.co"))
])

public extension DeploymentMethod {
    // Requires AWS CLI to be installed
    static func s3(_ bucket: String) -> Self {
        DeploymentMethod(name: "S3 (\(bucket))") { context in
            let s3 = try context.createDeploymentFolder(withPrefix: "s3_", configure: { _ in })
            // HTML
            try shellOut(
                to: "aws s3 sync \(s3.path) s3://\(bucket) --exclude '*' --exclude '*.DS_Store' --include 'posts/*' --include 'page/*' --include 'index.html' --content-type 'text/html'",
                outputHandle: FileHandle.standardOutput)
            // Resources
            try shellOut(
                to: "aws s3 sync \(s3.path) s3://\(bucket) --include '*' --exclude 'posts/*' --exclude 'page/*' --exclude 'index.html' --exclude '*.DS_Store'",
                outputHandle: FileHandle.standardOutput)
        }
    }
}
