import Foundation
import Publish
import Plot

// This type acts as the configuration for your website.
struct MakeSite: Website {
    enum SectionID: String, WebsiteSectionID {
        // Add the sections that you want your website to contain here:
        case posts
    }

    struct ItemMetadata: WebsiteItemMetadata {
        // Add any site-specific metadata that you want to use here.
    }

    // Update these properties to configure your website:
    var url = URL(string: "https://kaitomuraoka.github.io/PublishSampleWeb/")!
    var name = "MakeSite"
    var description = "A description of MakeSite"
    var language: Language { .japanese }
    var imagePath: Path? { nil }
}

// This will generate your website using the built-in Foundation theme:
//try MakeSite().publish(withTheme: .foundation)
try MakeSite().publish(using: [
    .addMarkdownFiles(),
    .generateHTML(withTheme: .iosOsushi)
])
