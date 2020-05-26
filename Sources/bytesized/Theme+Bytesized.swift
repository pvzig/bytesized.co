
import Foundation
import Plot
import Publish

public extension Theme {
    static var bytesized: Self {
        Theme(
            htmlFactory: BytesizedHTMLFactory(),
            resourcePaths: []
        )
    }
}

private struct BytesizedHTMLFactory<Site: Website>: HTMLFactory {
    
    var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        return formatter
    }
    
    func makeIndexHTML(for index: Index,
                       context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(site: context.site, location: index),
            .body(
                .header(for: context),
                .itemList(for: context.allItems().chunked(into: 5).first!),
                .paginator(currentPage: nil, context: context),
                .footer(for: context.site)
                )
            )
    }

    func makeItemHTML(for item: Item<Site>,
                      context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .div(.class("pure-g"),
                     .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4")),
                     .div(.class("pure-u-1-1 pure-u-md-5-6 pure-u-lg-1-2"),
                          .header(for: context),
                          .title(item: item as! Item<Bytesized>),
                          .date(item: item as! Item<Bytesized>),
                          .div(.class("content"), .raw(item.commonMarkBody))
                     ),
                     .div(.class("pure-u-0-4 pure-u-md-1-12 pure-u-lg-1-4"))
                ),
                .footer(for: context.site)
            )
        )
    }

    func makePageHTML(for page: Page,
                      context: PublishingContext<Site>) throws -> HTML {
        return HTML(
            .body(page.content.body.node)
        )
    }
    
    func makeSectionHTML(for section: Section<Site>,
                         context: PublishingContext<Site>) throws -> HTML {
        HTML()
    }
    
    func makeTagListHTML(for page: TagListPage, context: PublishingContext<Site>) throws -> HTML? {
        return nil
    }
    
    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws -> HTML? {
        return nil
    }
}

extension Website {
    var byline: String { "by Peter Zignego" }
    var footer: String { "Copyright © 2020 Peter Zignego" }
}

private extension Node where Context == HTML.DocumentContext {
    static func head<T: Website>(site: T, location: Location) -> Node {
        return .head(
            .meta(.charset(.utf8)),
            .meta(.name("viewport"), .content("width=device-width, initial-scale=1")),
            .meta(.name("description"), .content(site.description)),
            .title(location.title),
            .link(.rel(.stylesheet), .href("/css/styles.css"), .type("text/css")),
            .link(.rel(.stylesheet), .href("/css/normalized.css"), .type("text/css")),
            .link(.rel(.stylesheet), .href("/css/pure/pure-min.css"), .type("text/css")),
            .link(.rel(.stylesheet), .href("/css/pure/grids-responsive-min.css"), .type("text/css")),
            .link(.rel(.stylesheet), .href("https://cloud.typography.com/6607452/6761212/css/fonts.css"), .type("text/css")),
            .link(.rel(.icon), .href("/images/favico.ico"), .sizes("32x32"))
        )
    }
}

extension PublishingContext {
    func allItems<T: Website>() -> [Item<T>] {
        return sections.flatMap { $0.items } as! [Item<T>]
    }
    
    func pageContent(for page: Int, items: [Item<Bytesized>]) -> Content {
        let body = HTML(
            .lang(self.site.language),
            .head(site: self.site, location: index),
            .body(
                .header(for: self),
                .itemList(for: items),
                .paginator(currentPage: page, context: self),
                .footer(for: self.site)
            )
        )

        return Content(body: Content.Body(html: body.render()))
    }
}

private extension Node where Context == HTML.BodyContext {
    static var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM.dd.yyyy"
        return formatter
    }
    
    static func header<T: Website>(for context: PublishingContext<T>) -> Node {
        return .header(.class("header"),
            .a(.class("site-name"), .href("/"), .text(context.site.name)),
            .div(.class("byline"), .text(context.site.byline))
        )
    }
    
    static func itemList(for items: [Item<Bytesized>]) -> Node {
        return .forEach(items) { item in
            .group([
                .div(.class("title"), .a(.href(item.metadata.permalink), .text(item.metadata.title))),
                .div(.class("date"), .text(dateFormatter.string(from: item.metadata.date))),
                .div(.class("content"), .raw(item.commonMarkBody))
            ])
        }
    }
    
    static func title(item: Item<Bytesized>) -> Node {
        .div(.class("title"), .a(.href(item.metadata.permalink), .text(item.metadata.title)))
    }
    
    static func date(item: Item<Bytesized>) -> Node {
        .div(.class("date"), .text(dateFormatter.string(from: item.metadata.date)))
    }

    static func footer<T: Website>(for site: T) -> Node {
        return .footer(.class("footer"),
            .div(.style("text-align:center"), .text(site.footer))
        )
    }

    static func paginator<T: Website>(currentPage: Int?, context: PublishingContext<T>) -> Node {
        if let page = currentPage {
            let nextPage = page + 1
            let previousPage = page - 1
            let isMore = context.sections.flatMap { $0.items }.count > page * 5
            let previousLink = previousPage == 0 ? "index.html" : "\(previousPage).html"
            if isMore {
                return .div(.class("footer"), .style("min-height: 30px"),
                            .a(.href(previousLink), .class("previous"), .text("← previous")),
                            .div(.style("float: right"), .a(.href("\(nextPage).html"), .class("next"), .text("more →")))
                )
            } else {
                return .div(.class("footer"), .style("min-height: 30px"),
                            .a(.href("\(previousPage).html"), .class("previous"), .text("← previous"))
                )
            }
        // Index
        } else {
            return .div(.style("float: right"), .a(.href("1.html"), .class("next"), .text("more →")))
        }
    }
}
