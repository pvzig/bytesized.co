import Foundation
import Plot
import Publish
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

    func publishAsync(
        at path: Path? = nil,
        using steps: [PublishingStep<Self>],
        file: StaticString = #filePath
    ) async throws -> PublishedWebsite<Self> {
        let publish:
            (Path?, [PublishingStep<Self>], StaticString) async throws
                -> PublishedWebsite<Self> = self.publish
        return try await publish(path, steps, file)
    }
}

func parseBytesizedContent(_ text: String, metadata: Bytesized.ItemMetadata) -> Content {
    Content(body: Content.Body(stringLiteral: commonMarkBody(text, metadata: metadata)))
}

func applyBytesizedMetadata(_ item: inout Item<Bytesized>) {
    item.content.title = item.metadata.title
    item.content.date = item.metadata.date
}

func copyBytesizedCafeApp(using context: PublishingContext<Bytesized>) throws {
    let fileManager = FileManager.default
    let sourceFolder = try context.folder(at: Path("bytesized-cafe-app"))
    let destinationFolder = try context.createOutputFolder(at: Path("bytesized-cafe-app"))
    try destinationFolder.delete()
    try fileManager.copyItem(at: sourceFolder.url, to: destinationFolder.url)
}

_ = try await Bytesized().publishAsync(using: [
    .step(named: "Custom Date Formatter") { context in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        context.dateFormatter = formatter
    },
    .copyResources(
        at: Path("Resources/images"), to: Path("images"), includingFolder: false),
    .copyFile(at: Path("Resources/css/normalized.css"), to: Path("css")),
    .copyFile(at: Path("Resources/css/styles.css"), to: Path("css")),
    .copyFile(at: Path("Resources/css/pure/pure-min.css"), to: Path("css/pure")),
    .copyFile(at: Path("Resources/css/pure/grids-responsive-min.css"), to: Path("css/pure")),
    .copyResources(at: Path("Resources/fonts"), to: Path("fonts"), includingFolder: false),
    .addMarkdownFiles(customContentParser: parseBytesizedContent),
    .step(named: "Name Index") { context in
        context.index.title = context.site.name
    },
    .mutateAllItems(using: applyBytesizedMetadata),
    .sortItems(by: \.metadata.date, order: .descending),
    .step(named: "Paginate") { context in
        for section in context.sections.ids {
            let chunks = context.sections[section].items.chunked(into: 5)
            for (i, chunk) in chunks.enumerated() {
                // Index
                if i == 0 {
                    continue
                }
                let page = Page(
                    path: "/page/\(i)/index.html",
                    content: context.pageContent(for: i, items: chunk))
                context.addPage(page)
            }
        }
    },
    .generateHTML(withTheme: .bytesized, fileMode: .standAloneFilesClean),
    .generateRSSFeed(including: [.posts]),
    .step(named: "Copy Bytesized Cafe app") { context in
        try copyBytesizedCafeApp(using: context)
    },
    .deploy(using: .s3("bytesized.co")),
])

extension DeploymentMethod {
    // Requires AWS CLI to be installed
    public static func s3(_ bucket: String) -> Self {
        DeploymentMethod(name: "S3 (\(bucket))") { context in
            let s3 = try context.createDeploymentFolder(withPrefix: "s3_", configure: { _ in })
            // HTML
            try shellOut(
                to:
                    "aws s3 sync \(s3.path) s3://\(bucket) --exclude '*' --exclude '*.DS_Store' --include 'posts/*' --include 'page/*' --include 'index.html' --content-type 'text/html'",
                outputHandle: FileHandle.standardOutput)
            // Resources
            try shellOut(
                to:
                    "aws s3 sync \(s3.path) s3://\(bucket) --include '*' --exclude 'posts/*' --exclude 'page/*' --exclude 'index.html' --exclude '*.DS_Store'",
                outputHandle: FileHandle.standardOutput)
        }
    }
}
