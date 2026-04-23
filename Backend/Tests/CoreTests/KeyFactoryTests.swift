import Foundation
import Testing

@testable import Core

struct KeyFactoryTests {
    @Test func pageImageKeyBuildsDailyReadableCachePath() {
        let keyFactory = KeyFactory()

        let key = keyFactory.pageImageKey(
            prefix: "/generated/v2/",
            date: Date(timeIntervalSince1970: 0),
            context: PageContext(
                pagePath: "/posts/Cafe-con-leche/",
                pageType: .article
            ),
            countryName: "Côte d'Ivoire"
        )

        #expect(
            key
                == "generated/v2/page-cache/1970/01/01/article/posts/cafe-con-leche-cote-d-ivoire.png"
        )
    }

    @Test func pageImageKeyFallsBackToRootAndAnywhere() {
        let keyFactory = KeyFactory()

        let key = keyFactory.pageImageKey(
            prefix: "generated/v2",
            date: Date(timeIntervalSince1970: 0),
            context: PageContext(
                pagePath: "/",
                pageType: .index
            )
        )

        #expect(key == "generated/v2/page-cache/1970/01/01/index/root-anywhere.png")
    }

    @Test func pageImageKeyChangesWithUTCDate() {
        let keyFactory = KeyFactory()
        let context = PageContext(
            pagePath: "/posts/Cafe-con-leche/",
            pageType: .article
        )

        let firstDayKey = keyFactory.pageImageKey(
            prefix: "generated/v2",
            date: Date(timeIntervalSince1970: 0),
            context: context
        )
        let nextDayKey = keyFactory.pageImageKey(
            prefix: "generated/v2",
            date: Date(timeIntervalSince1970: 86_400),
            context: context
        )

        #expect(firstDayKey != nextDayKey)
        #expect(firstDayKey.contains("/1970/01/01/"))
        #expect(nextDayKey.contains("/1970/01/02/"))
    }
}
