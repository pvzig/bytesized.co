
import Foundation

func footnotes(html: String, date: Date) -> String {
     let formatter = DateFormatter()
     formatter.dateFormat = "yyyy-MM-dd"
     // Match footnote references
     func removeParagraphTags(_ string: String) -> String {
         do {
             let detagger = try NSRegularExpression(pattern: "(<p[^>]+?>|<p>|<\\/p>)", options: [])
             return detagger.stringByReplacingMatches(in: string, options: [], range: NSMakeRange(0, string.utf16.count), withTemplate: "")
         } catch _ {
             return string
         }
     }

     do {
         var str = html
         let olExpression = try NSRegularExpression(pattern: "\\[\\^\\d*]:.*", options: .dotMatchesLineSeparators)

         /// Remove stray <p> and </p> tags from our footnotes
         let match = olExpression.firstMatch(in: str, options: [], range: NSMakeRange(0, str.utf16.count))
         if let range = match?.range {
             let substring = NSString(string: str).substring(with: range)
             str = str.replacingOccurrences(of: substring, with: removeParagraphTags(substring))
         }

         /// Add a divider and make the section an ordered list
         let olTemplate = "</p><hr/><ol>$0</ol>"
         str = olExpression.stringByReplacingMatches(in: str, options: [], range: NSMakeRange(0, str.utf16.count), withTemplate: olTemplate)

         /// Turn references in the style `[^n]:` into links
         let fnrExpression = try NSRegularExpression(pattern: "(\\[\\^(\\d*)]:)\\s(.*)$", options: .anchorsMatchLines)
         let fnrTemplate = "<li id=\"fn$2-\(formatter.string(from: date))\"><p>$3<a href=\"#fnr$2-\(formatter.string(from: date))\">↩︎</a></p></li>"
         str = fnrExpression.stringByReplacingMatches(in: str, options: [], range: NSMakeRange(0, str.utf16.count), withTemplate: fnrTemplate)

         /// Turn footnote references in the style `[^1]` into superscript links
         let fnExpression = try NSRegularExpression(pattern: "(\\[\\^([\\d]+)\\])", options: [])
         let fnTemplate = "<sup id=\"fnr$2-\(formatter.string(from: date))\"><a href=\"#fn$2-\(formatter.string(from: date))\">$2</a></sup>"
         str = fnExpression.stringByReplacingMatches(in: str, options: [], range: NSMakeRange(0, str.utf16.count), withTemplate: fnTemplate)
         return str
     } catch _ {
         return html
     }
}
