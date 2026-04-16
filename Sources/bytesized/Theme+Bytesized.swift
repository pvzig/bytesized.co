import Foundation
import Plot
import Publish

private let dateFormat = "MM.dd.yyyy"

extension Theme {
    public static var bytesized: Self {
        Theme(
            htmlFactory: BytesizedHTMLFactory(),
            resourcePaths: []
        )
    }
}

private struct BytesizedHTMLFactory<Site: Website>: HTMLFactory {

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter
    }

    func makeIndexHTML(
        for index: Index,
        context: PublishingContext<Site>
    ) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(site: context.site, location: index),
            .body(
                .div(
                    .class("pure-g"),
                    .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4")),
                    .div(
                        .class("pure-u-1-1 pure-u-md-5-6 pure-u-lg-1-2"),
                        .header(for: context, pagePath: "/", pageType: .index),
                        .itemList(for: context.allItems.chunked(into: 5).first ?? []),
                        .paginator(currentPage: 0, context: context)
                    ),
                    .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4"))
                ),
                .footer(for: context.site),
                .bytesizedCafeScripts
            )
        )
    }

    func makeItemHTML(
        for item: Item<Site>,
        context: PublishingContext<Site>
    ) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(site: context.site, location: item),
            .body(
                .div(
                    .class("pure-g"),
                    .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4")),
                    .div(
                        .class("pure-u-1-1 pure-u-md-5-6 pure-u-lg-1-2"),
                        .header(
                            for: context,
                            pagePath: item.path.absoluteString,
                            pageType: .article
                        ),
                        .title(item: item.bytesized),
                        .date(item: item.bytesized),
                        .div(.class("content"), item.content.body.node)
                    ),
                    .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4"))
                ),
                .footer(for: context.site),
                .bytesizedCafeScripts
            )
        )
    }

    // Paginated
    func makePageHTML(
        for page: Page,
        context: PublishingContext<Site>
    ) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(site: context.site, location: page),
            .body(page.content.body.node)
        )
    }

    func makeSectionHTML(
        for section: Section<Site>,
        context: PublishingContext<Site>
    ) throws -> HTML {
        HTML()
    }

    func makeTagListHTML(for page: TagListPage, context: PublishingContext<Site>) throws -> HTML? {
        return nil
    }

    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws
        -> HTML?
    {
        return nil
    }
}

extension Node where Context == HTML.DocumentContext {
    fileprivate static func head<T: Website>(site: T, location: Location) -> Node {
        return .head(
            .meta(.charset(.utf8)),
            .meta(.name("viewport"), .content("width=device-width, initial-scale=1")),
            .meta(.name("description"), .content(site.description)),
            .title(location.title),
            .link(.rel(.stylesheet), .href("/css/styles.css"), .type("text/css")),
            .link(.rel(.stylesheet), .href("/css/normalized.css"), .type("text/css")),
            .link(.rel(.stylesheet), .href("/css/pure/pure-min.css"), .type("text/css")),
            .link(
                .rel(.stylesheet), .href("/css/pure/grids-responsive-min.css"), .type("text/css")),
            .link(.rel(.icon), .href("/images/favico.ico"), .sizes("32x32")),
            .link(.rel(.appleTouchIcon), .href("/images/ico.png")),
            .link(.rel(.alternate), .href("/feed.rss"), .type("application/rss+xml"))
        )
    }
}

extension PublishingContext {
    var allItems: [Item<Site>] {
        sections.flatMap { $0.items }
    }

    func archivePagePath(for page: Int) -> String {
        page == 0 ? "/" : "/page/\(page)/index.html"
    }

    func pageContent<T: Website>(for page: Int, items: [Item<T>]) -> Content {
        let body = HTML(
            .body(
                .div(
                    .class("pure-g"),
                    .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4")),
                    .div(
                        .class("pure-u-1-1 pure-u-md-5-6 pure-u-lg-1-2"),
                        .header(
                            for: self,
                            pagePath: archivePagePath(for: page),
                            pageType: .archive
                        ),
                        .itemList(for: items),
                        .paginator(currentPage: page, context: self)
                    ),
                    .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4"))
                ),
                .footer(for: site),
                .bytesizedCafeScripts
            )
        )

        return Content(title: site.name, body: Content.Body(html: body.render()))
    }
}

extension Node where Context == HTML.BodyContext {
    fileprivate static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter
    }

    fileprivate static func header<T: Website>(
        for context: PublishingContext<T>,
        pagePath: String,
        pageType: BytesizedCafePageType
    ) -> Node {
        let configuration = BytesizedCafeConfiguration.current

        return .header(
            .class("header"),
            .a(
                .class("site-name"),
                .href("/"),
                .bytesizedCafeMount(
                    pagePath: pagePath,
                    pageType: pageType,
                    configuration: configuration
                )
            )
        )
    }

    fileprivate static func itemList<T: Website>(for items: [Item<T>]) -> Node {
        return .forEach(items) { item in
            .group([
                .div(
                    .class("title"),
                    .a(.href(item.path.absoluteString), .text(item.bytesized.metadata.title))
                ),
                .div(
                    .class("date"), .text(dateFormatter.string(from: item.bytesized.metadata.date))),
                .div(.class("content"), item.content.body.node),
            ])
        }
    }

    fileprivate static func title(item: Item<Bytesized>) -> Node {
        .div(.class("title"), .a(.href(item.path.absoluteString), .text(item.metadata.title)))
    }

    fileprivate static func date(item: Item<Bytesized>) -> Node {
        .div(.class("date"), .text(dateFormatter.string(from: item.metadata.date)))
    }

    fileprivate static func footer<T: Website>(for site: T) -> Node {
        .footer(.class("footer"), .div(.style("text-align:center"), .text(site.footer)))
    }

    fileprivate static func paginator<T: Website>(currentPage: Int, context: PublishingContext<T>)
        -> Node
    {
        func next(path: String) -> Node {
            .div(.style("float: right"), .a(.href(path), .class("next"), .text("more →")))
        }

        func previous(path: String) -> Node {
            .a(.href(path), .class("previous"), .text("← previous"))
        }

        let nextPage = currentPage + 1
        let previousPage = currentPage - 1
        let previousLink = context.archivePagePath(for: previousPage)
        let nextLink = context.archivePagePath(for: nextPage)
        let isNext = context.allItems.count > nextPage * 5
        let isPrevious = currentPage != 0

        return .div(
            .class("footer"), .style("min-height: 30px"),
            .if(isPrevious, previous(path: previousLink)),
            .if(isNext, next(path: nextLink))
        )
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
