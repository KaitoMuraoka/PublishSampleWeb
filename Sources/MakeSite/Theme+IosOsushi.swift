//
//  Theme+IosOsushi.swift
//  MakeSite
//
//  Created by 村岡海人 on 2024/10/27.
//

import Publish
import Plot
import Foundation

public extension Theme {
    static var iosOsushi: Self {
        Theme(
            htmlFactory: IosOsushiHTMLFactory(),
            resourcePaths: ["Resources/SampleCSS/styles.css"]
        )
    }
}

private struct IosOsushiHTMLFactory<Site: Website>: HTMLFactory {
    func makeIndexHTML(for index: Index, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: index, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper {
                    H1(index.title)
                    Paragraph(context.site.description)
                        .class("description")
                    H2("最新の投稿")
                    ItemList(
                        items: context.allItems(
                            sortedBy: \.date,
                            order: .descending
                        ),
                        site: context.site
                    )
                }
                SiteFooter()
            }
        )
    }

    func makeSectionHTML(for section: Section<Site>, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: section, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: section.id)
                Wrapper {
                    H1(section.title)
                    ItemList(items: section.items, site: context.site)
                }
                SiteFooter()
            }
        )
    }

    func makeItemHTML(for item: Item<Site>, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: item, on: context.site),
            .body(
                .script(.async(), .src("https://platform.twitter.com/widgets.js")),
                .script(.async(), .src("https://b.st-hatena.com/js/bookmark_button.js")),
                .class("item-page"),
                .components {
                    SiteHeader(context: context, selectedSelectionID: item.sectionID)
                    Wrapper {
                        Article {
                            Div {
                                TweetButton(item: item, site: context.site)
                                HatebButton()
                            }
                            .class("share-buttons")
                            Div(item.content.body).class("content")
                        }
                    }
                    SiteFooter()
                }
            )
        )
    }

    func makePageHTML(for page: Page, context: PublishingContext<Site>) throws -> HTML {
        HTML(
            .lang(context.site.language),
            .head(for: page, on: context.site),
            .body {
                SiteHeader(context: context, selectedSelectionID: nil)
                Wrapper(page.body)
                SiteFooter()
            }
        )
    }

    func makeTagListHTML(for page: TagListPage, context: PublishingContext<Site>) throws -> HTML? {
        nil
    }

    func makeTagDetailsHTML(for page: TagDetailsPage, context: PublishingContext<Site>) throws -> HTML? {
        nil
    }

    private struct TweetButton<Site: Website>: Component {
        private var tweetText: String { "\(item.title) | \(site.name)" }
        private var urlString: String { site.url.absoluteString + item.path.absoluteString }
        private let hashtag = "ios_osushi"
        private let username = "ios_osushi"

        var item: Item<Site>
        var site: Site
        var body: Component {
            Link("ツイート", url: "https://twitter.com/intent/tweet?text=\(tweetText.urlEncoded())&url=\(urlString.urlEncoded())&hashtags=\(hashtag.urlEncoded())&via=\(username.urlEncoded())")
                .class("twitter-share-button")
        }
    }

    private struct HatebButton: Component {
        var body: Component {
            Link(url: "https://b.hatena.ne.jp/entry/") {
                Image(
                    url: "https://b.st-hatena.com/images/v4/public/entry-button/button-only@2x.png",
                    description: "このエントリーをはてなブックマークに追加"
                )
                .attribute(named: "width", value: "20")
                .attribute(named: "height", value: "20")
                .style("border: none;")
            }
            .class("hatena-bookmark-button")
            .data(named: "hatena-bookmark-layout", value: "basic-label-counter")
            .data(named: "hatena-bookmark-lang", value: "ja")
            .attribute(named: "title", value: "このエントリーをはてなブックマークに追加")
        }
    }
}

private struct Wrapper: ComponentContainer {
    @ComponentBuilder var content: ContentProvider

    var body: Component {
        Div(content: content).class("wrapper")
    }
}

private struct SiteHeader<Site: Website>: Component {
    var context: PublishingContext<Site>
    var selectedSelectionID: Site.SectionID?

    var body: Component {
        Header {
            Wrapper {
                Link(context.site.name, url: "/")
                    .class("site-name")

                if Site.SectionID.allCases.count > 1 {
                    navigation
                }
            }
        }
    }

    private var navigation: Component {
        Navigation {
            List(Site.SectionID.allCases) { sectionID in
                let section = context.sections[sectionID]

                return Link(section.title, url: section.path.absoluteString)
                    .class(sectionID == selectedSelectionID ? "selected" : "")
            }
        }
    }
}

private struct ItemList<Site: Website>: Component {
    var items: [Item<Site>]
    var site: Site

    var body: Component {
        List(items) { item in
            Article {
                H1(Link(item.title, url: item.path.absoluteString))
                Paragraph(item.description)
            }
        }
        .class("item-list")
    }
}

private struct SiteFooter: Component {
    var body: Component {
        Footer {
            Paragraph {
                Text("© 2022-2024 iOS Osushi")
            }
            Paragraph {
                Text("Generated using ")
                Link("Publish", url: "https://github.com/johnsundell/publish")
            }
            Paragraph {
                Link("X（旧 Twitter）", url: "https://x.com/ios_osushi")
                Text(" | ")
                Link("GitHub", url: "https://github.com/ios-osushi")
                Text(" | ")
                Link("RSS", url: "/feed.rss")
            }
        }
    }
}

extension String {
    func urlEncoded() -> String {
        let allowedChars = CharacterSet.alphanumerics.union(.init(charactersIn: "/?-._~"))
        let decoded = removingPercentEncoding ?? self
        return decoded.addingPercentEncoding(withAllowedCharacters: allowedChars) ?? decoded
    }
}
