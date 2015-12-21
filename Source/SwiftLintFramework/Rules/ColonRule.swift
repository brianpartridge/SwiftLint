//
//  ColonRule.swift
//  SwiftLint
//
//  Created by JP Simard on 2015-05-16.
//  Copyright (c) 2015 Realm. All rights reserved.
//

import SourceKittenFramework

public struct ColonRule: CorrectableRule {
    public static let description = RuleDescription(
        identifier: "colon",
        name: "Colon",
        description: "Colons should be next to the identifier when specifying a type.",
        nonTriggeringExamples: [
            "let abc: Void\n",
            "let abc: [Void: Void]\n",
            "let abc: (Void, Void)\n",
            "let abc: String=\"def\"\n",
            "let abc: Int=0\n",
            "let abc: Enum=Enum.Value\n",
            "func abc(def: Void) {}\n",
            "func abc(def: Void, ghi: Void) {}\n",
            "// 周斌佳年周斌佳\nlet abc: String = \"abc:\""
        ],
        triggeringExamples: [
            "let abc:Void\n",
            "let abc:  Void\n",
            "let abc :Void\n",
            "let abc : Void\n",
            "let abc : [Void: Void]\n",
            "let abc :String=\"def\"\n",
            "let abc :Int=0\n",
            "let abc :Int = 0\n",
            "let abc:Int=0\n",
            "let abc:Int = 0\n",
            "let abc:Enum=Enum.Value\n",
            "func abc(def:Void) {}\n",
            "func abc(def:  Void) {}\n",
            "func abc(def :Void) {}\n",
            "func abc(def : Void) {}\n",
            "func abc(def: Void, ghi :Void) {}\n"
        ],
        corrections: [
            "let abc:Void\n": "let abc: Void\n",
            "let abc:  Void\n": "let abc: Void\n",
            "let abc :Void\n": "let abc: Void\n",
            "let abc : Void\n": "let abc: Void\n",
            "let abc : [Void: Void]\n": "let abc: [Void: Void]\n",
            "let abc :String=\"def\"\n": "let abc: String=\"def\"\n",
            "let abc :Int=0\n": "let abc: Int=0\n",
            "let abc :Int = 0\n": "let abc: Int = 0\n",
            "let abc:Int=0\n": "let abc: Int=0\n",
            "let abc:Int = 0\n": "let abc: Int = 0\n",
            "let abc:Enum=Enum.Value\n": "let abc: Enum=Enum.Value\n",
            "func abc(def:Void) {}\n": "func abc(def: Void) {}\n",
            "func abc(def:  Void) {}\n": "func abc(def: Void) {}\n",
            "func abc(def :Void) {}\n": "func abc(def: Void) {}\n",
            "func abc(def : Void) {}\n": "func abc(def: Void) {}\n",
            "func abc(def: Void, ghi :Void) {}\n": "func abc(def: Void, ghi: Void) {}\n", //end
//            "let abc: Void\n": "let abc: Void\n",
//            "let abc: [Void: Void]\n": "let abc: [Void: Void]\n",
//            "let abc: (Void, Void)\n": "let abc: (Void, Void)\n",
//            "let abc: String=\"def\"\n": "let abc: String=\"def\"\n",
//            "let abc: Int=0\n": "let abc: Int=0\n",
//            "let abc: Enum=Enum.Value\n": "let abc: Enum=Enum.Value\n",
//            "func abc(def: Void) {}\n": "func abc(def: Void) {}\n",
//            "func abc(def: Void, ghi: Void) {}\n": "func abc(def: Void, ghi: Void) {}\n",
            "// 周斌佳年周斌佳\nlet abc: String = \"abc:\"": "// 周斌佳年周斌佳\nlet abc: String = \"abc:\""
        ]
    )

    private let spacingLeftOfColonPattern = "(\\w+)\\s+:\\s*(\\S+)"
    private let spacingRightOfColonPattern = "(\\w+):(?:\\s{0}|\\s{2,})(\\S+)"
    private func patterns() -> [String] {
        return [spacingLeftOfColonPattern, spacingRightOfColonPattern]
    }

    public func validateFile(file: File) -> [StyleViolation] {
        let pattern = (patterns() as NSArray).componentsJoinedByString("|")

        return file.matchPattern(pattern).flatMap { range, syntaxKinds in
            if !syntaxKinds.startsWith([.Identifier, .Typeidentifier]) {
                return nil
            }

            return StyleViolation(ruleDescription: self.dynamicType.description,
                location: Location(file: file, offset: range.location))
        }
    }

    public func correctFile(file: File) -> [Correction] {
        let replacementTemplate = "$1: $2"
        var corrections = [Correction]()
        var contents = file.contents
        let regexes = patterns().map { regex($0) }
        for regex in regexes {
            let range = NSRange(location: 0, length: contents.characters.count)
            let matchingRanges = file.matchPattern(pattern, excludingSyntaxKinds: [SyntaxKind.commentAndStringKinds()])
            for matchingRange in matchingRanges {
                let description = self.dynamicType.description
                let location = Location(file: file, offset: matchingRange.location)
                corrections.append(Correction(ruleDescription: description, location: location))
            }
            contents = regex.stringByReplacingMatchesInString(contents,
                options: [],
                range: range,
                withTemplate: replacementTemplate)
        }
        if !corrections.isEmpty {
            file.write(contents)
            return corrections
        }
        return []
    }
}
