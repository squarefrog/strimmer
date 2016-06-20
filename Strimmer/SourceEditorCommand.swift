//
//  SourceEditorCommand.swift
//  Strimmer
//
//  Created by Paul Williamson on 20/06/2016.
//  Copyright © 2016 squarefrog. All rights reserved.
//

import Foundation
import XcodeKit

class SourceEditorCommand: NSObject, XCSourceEditorCommand {
    func perform(with invocation: XCSourceEditorCommandInvocation, completionHandler: (NSError?) -> Void ) -> Void {

        // Keep an array of changed line indices.
        var changedLineIndexes = [Int]()

        // Loop through each line in the buffer, searching for trailing whitespace and replace only
        // the trailing whitespace.
        for lineIndex in 0 ..< invocation.buffer.lines.count {
            let originalLine = invocation.buffer.lines[lineIndex] as! String
            let newLine = originalLine.replacingOccurrences(of: "[ \t]+$",
                                                            with: "",
                                                            options: .regularExpressionSearch)

            // Only update lines that have changed.
            if originalLine != newLine {
                changedLineIndexes.append(lineIndex)
                invocation.buffer.lines[lineIndex] = newLine
            }
        }

        // Select all lines that were replaced.
        let updatedSelections: [XCSourceTextRange] = changedLineIndexes.map { lineIndex in
            let lineSelection = XCSourceTextRange()
            lineSelection.start = XCSourceTextPosition(line: lineIndex, column: 0)
            lineSelection.end = XCSourceTextPosition(line: lineIndex + 1, column: 0)
            return lineSelection
        }

        // Set selections then return with no error.
        invocation.buffer.selections.setArray(updatedSelections)
        completionHandler(nil)
    }
}
