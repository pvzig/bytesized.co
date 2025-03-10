
import Foundation
import Publish
import CommonMark
import Splash

extension Item {
    var bytesized: Item<Bytesized> {
        return self as! Item<Bytesized>
    }
}

func commonMarkBody(_ content: String, metadata: Bytesized.ItemMetadata) -> String {
    do {
        let stripped = content.stripMetadata()
        let cmark = try Document(stripped)
        let html = cmark.render(format: .html, options: .unsafe)
        let htmlWithSyntaxHighlighting = applySyntaxHighlighting(to: html)
        return htmlWithSyntaxHighlighting.parseMarkdownFootnotes(date: metadata.date)
    } catch let error {
        fatalError("Failed to generate CommonMark body with error: \(error.localizedDescription)")
    }
}

func applySyntaxHighlighting(to html: String) -> String {
    do {
        // Pattern captures an optional language attribute and the code content.
        // Group 1: if present, should be "language-swift"
        // Group 2: the actual code content.
        let pattern = #"<pre><code(?:\s+class="(language-swift)")?>(.*?)</code></pre>"#
        let regex = try NSRegularExpression(
            pattern: pattern,
            options: [.dotMatchesLineSeparators]
        )
        
        // Create a mutable copy to perform in-place replacements.
        let mutableHTML = NSMutableString(string: html)
        let matches = regex.matches(
            in: html,
            options: [],
            range: NSRange(location: 0, length: html.utf16.count)
        )
        
        // Initialize your syntax highlighter.
        let highlighter = SyntaxHighlighter(format: HTMLOutputFormat(classPrefix: "splash-"))
        
        // Process matches in reverse order so earlier ranges remain valid.
        for match in matches.reversed() {
            // Group 1: language attribute (if any); Group 2: code content.
            let languageRange = match.range(at: 1)
            let codeRange = match.range(at: 2)
            guard codeRange.location != NSNotFound,
                  let swiftCodeRange = Range(codeRange, in: html) else {
                continue
            }
            
            let codeContent = String(html[swiftCodeRange]).decodedHTMLEntities
            // Only highlight if the language is explicitly Swift.
            let isSwiftBlock = languageRange.location != NSNotFound
            let processedCode = isSwiftBlock ? highlighter.highlight(codeContent) : codeContent
            
            // Recreate the code block with proper class if it was a Swift block.
            let classAttribute = isSwiftBlock ? " class=\"language-swift\"" : ""
            let replacementHTML = "<pre><code\(classAttribute)>\(processedCode)</code></pre>"
            
            // Replace the entire match in the mutable HTML.
            mutableHTML.replaceCharacters(in: match.range, with: replacementHTML)
        }
        
        return mutableHTML as String
    } catch {
        print("Error applying syntax highlighting: \(error.localizedDescription)")
        return html
    }
}

extension String {
    /// Decodes a few common HTML entities.
    var decodedHTMLEntities: String {
        let entities = [
            "&lt;": "<",
            "&gt;": ">",
            "&quot;": "\"",
            "&amp;": "&"
        ]
        return entities.reduce(self) { result, pair in
            result.replacingOccurrences(of: pair.key, with: pair.value)
        }
    }
}

