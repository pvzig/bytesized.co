import Testing

@testable import Core

struct KeyFactoryTests {
    @Test func pageImageKeyBuildsStableReadableCachePath() {
        let keyFactory = KeyFactory()

        let key = keyFactory.pageImageKey(
            prefix: "/generated/v2/",
            context: PageContext(
                pagePath: "/posts/Cafe-con-leche/",
                pageType: .article
            ),
            countryName: "Côte d'Ivoire"
        )

        #expect(
            key == "generated/v2/page-cache/article/posts/cafe-con-leche-cote-d-ivoire.png")
    }

    @Test func pageImageKeyFallsBackToRootAndAnywhere() {
        let keyFactory = KeyFactory()

        let key = keyFactory.pageImageKey(
            prefix: "generated/v2",
            context: PageContext(
                pagePath: "/",
                pageType: .index
            )
        )

        #expect(key == "generated/v2/page-cache/index/root-anywhere.png")
    }
}
