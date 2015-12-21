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
            "func abc(def: Void, ghi :Void) {}\n": "func abc(def: Void, ghi: Void) {}\n"
        ]
    )

    // Use \S+? for lazy evaluation, otherwise the expansion could include undesired SyntaxKinds.
    // Include \[? to handle the case where a type identifier is within '[]'.
    private let spacingLeftOfColonPattern = "(\\w+)\\s+:\\s*(\\[?\\S+?)"
    private let spacingRightOfColonPattern = "(\\w+):(?:\\s{0}|\\s{2,})(\\S+?)"
    private func patterns() -> [String] {
        return [spacingLeftOfColonPattern, spacingRightOfColonPattern]
    }

    private func validMatchesInFile(file: File, withPattern pattern: String) -> [NSRange] {
        return file.matchPattern(pattern).filter { range, syntaxKinds in
            if !syntaxKinds.startsWith([.Identifier, .Typeidentifier]) {
                return false
            }
            if Set(syntaxKinds).intersect(Set(SyntaxKind.commentAndStringKinds())).count > 0 {
                return false
            }
            return true
        }.flatMap { $0.0 }
    }

    public func validateFile(file: File) -> [StyleViolation] {
        let pattern = (patterns() as NSArray).componentsJoinedByString("|")
        return validMatchesInFile(file, withPattern: pattern).flatMap { range in
            return StyleViolation(ruleDescription: self.dynamicType.description,
                location: Location(file: file, offset: range.location))
        }
    }

    public func correctFile(file: File) -> [Correction] {
        return patterns().reduce([Correction]()) { corrections, pattern in
            return corrections + correctFile(file, withPattern: pattern)
        }
    }

    public func correctFile(file: File, withPattern pattern: String) -> [Correction] {
        let matches = validMatchesInFile(file, withPattern: pattern)
        guard !matches.isEmpty else { return [] }
        let regularExpression = regex(pattern)
        var corrections = [Correction]()
        var contents = file.contents
        for range in matches.reverse() {
            contents = regularExpression.stringByReplacingMatchesInString(contents,
                options: [], range: range, withTemplate: "$1: $2")
            let description = self.dynamicType.description
            let location = Location(file: file, offset: range.location)
            corrections.append(Correction(ruleDescription: description, location: location))
        }
        file.write(contents)
        return corrections
    }
}
