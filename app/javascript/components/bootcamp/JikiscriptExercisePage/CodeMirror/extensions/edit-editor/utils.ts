import { EditorView } from '@codemirror/view'
import { showTutorTooltip } from './customCursor'
import { addHighlight, removeAllHighlightEffect } from './highlightRange'
import { updateReadOnlyRangesEffect } from '../read-only-ranges/readOnlyRanges'
import { RegExpCursor } from '@codemirror/search'
import { changeMultiLineHighlightEffect } from '../multiLineHighlighter'

export function addCodeToEndOfLine(
  view: EditorView,
  { line, code }: { line: number; code: string }
): Promise<void> {
  return new Promise((resolve) => {
    const lineObj = view.state.doc.line(line)
    const pos = lineObj.to
    view.dispatch({
      changes: { from: pos, insert: code },
    })
    resolve()
  })
}

function randomNumberBetween(min: number, max: number): number {
  return Math.random() * (max - min) + min
}
export function typeOutCode(
  view: EditorView,
  { line, code }: { line: number; code: string }
): Promise<void> {
  return new Promise((resolve) => {
    const lineObj = view.state.doc.line(line)
    let pos = lineObj.to
    let index = 0

    view.focus()
    // move to the desired line first, and then show the tooltip
    view.dispatch({
      selection: { anchor: pos, head: pos },
      effects: showTutorTooltip.of(true),
    })

    const typeChar = () => {
      if (index < code.length) {
        const char = code.charAt(index)

        view.dispatch({
          changes: { from: pos, insert: char },
          selection: { anchor: pos + 1, head: pos + 1 },
        })

        pos += 1
        index += 1

        const interval = randomNumberBetween(30, 200)

        setTimeout(typeChar, interval)
      } else {
        resolve()
      }
    }

    setTimeout(typeChar, 100)
  })
}

export function backspaceLines(
  view: EditorView,
  { from, to }: { from: number; to: number }
): Promise<void> {
  return new Promise((resolve) => {
    const startPosObj = view.state.doc.line(from)
    const endPosObj = view.state.doc.line(to)
    let posStart = startPosObj.from
    let posEnd = endPosObj.to

    view.focus()
    // move to the desired line first, and then show the tooltip
    view.dispatch({
      selection: { anchor: posEnd, head: posEnd },
      effects: showTutorTooltip.of(true),
    })

    const deleteChar = () => {
      if (posStart < posEnd) {
        view.dispatch({
          changes: { from: posEnd - 1, to: posEnd },
        })

        posEnd -= 1

        const interval = randomNumberBetween(30, 100)

        setTimeout(deleteChar, interval)
      } else {
        resolve()
      }
    }

    setTimeout(deleteChar, 100)
  })
}

export function markLinesAsReadonly(
  view: EditorView,
  ranges: { from: number; to: number }[]
): Promise<void> {
  return new Promise((resolve) => {
    view.dispatch({
      effects: updateReadOnlyRangesEffect.of(ranges),
    })
    resolve()
  })
}
export function revertLinesToEditable(view: EditorView): Promise<void> {
  return new Promise((resolve) => {
    view.dispatch({
      effects: updateReadOnlyRangesEffect.of([]),
    })
    resolve()
  })
}

export function highlightCodeSelection(
  view: EditorView,
  {
    regex,
    ignoreCase,
    lines,
  }: {
    regex: string
    ignoreCase?: boolean
    lines?: { from: number; to: number }
  }
): Promise<void> {
  return new Promise((resolve) => {
    if (regex.length === 0) {
      resolve()
      return
    }

    const fromChar = lines ? view.state.doc.line(lines.from).from : 0
    const toChar = lines
      ? view.state.doc.line(lines.to).to
      : view.state.doc.length

    const cursor = new RegExpCursor(
      view.state.doc,
      regex,
      {
        ignoreCase: ignoreCase || false,
      },
      fromChar,
      toChar
    )

    while (!cursor.done) {
      const { from, to } = cursor.value
      if (from > -1 && to > -1) {
        view.dispatch({ effects: addHighlight.of({ from, to }) })
      }
      cursor.next()
    }
    resolve()
  })
}

export function removeAllHighlights(view: EditorView): Promise<void> {
  return new Promise((resolve) => {
    view.dispatch({ effects: removeAllHighlightEffect.of() })

    resolve()
  })
}

export function removeLine(
  view: EditorView,
  { line }: { line: number }
): Promise<void> {
  return new Promise((resolve) => {
    const lineObj = view.state.doc.line(line)
    let from = lineObj.from
    let to = lineObj.to
    if (line < view.state.doc.lines) {
      to += 1
    }

    view.dispatch({
      changes: { from, to, insert: '' },
    })
    resolve()
  })
}

export function placeCursor(
  view: EditorView,
  options: { line: number; char: number }
): Promise<void> {
  return new Promise((resolve) => {
    view.focus()
    view.dispatch({
      selection: {
        anchor: view.state.doc.line(options.line).from + options.char,
        head: view.state.doc.line(options.line).from + options.char,
      },
      effects: showTutorTooltip.of(true),
    })
    resolve()
  })
}

export function highlightEditorContent(view: EditorView): Promise<void> {
  return new Promise((resolve) => {
    const pos = view.state.doc.length
    view.focus()
    view.dispatch({
      selection: { anchor: pos, head: pos },
      effects: [
        showTutorTooltip.of(true),
        changeMultiLineHighlightEffect.of({
          from: 1,
          to: view.state.doc.lineAt(view.state.doc.length).number,
        }),
      ],
    })

    resolve()
  })
}

export function deleteEditorContent(view: EditorView): Promise<void> {
  return new Promise((resolve) => {
    const pos = view.state.doc.length
    view.focus()
    view.dispatch({
      selection: { anchor: pos, head: pos },
      effects: [
        showTutorTooltip.of(true),
        changeMultiLineHighlightEffect.of({
          from: 1,
          to: view.state.doc.lineAt(view.state.doc.length).number,
        }),
      ],
      scrollIntoView: true,
    })

    setTimeout(() => {
      view.dispatch({
        changes: {
          from: 0,
          to: view.state.doc.length,
          insert: '',
        },
        effects: changeMultiLineHighlightEffect.of({
          from: 0,
          to: 0,
        }),
      })
      resolve()
    }, 1000)
  })
}

// TODO: Recalculate character positions after removing lines
export function highlightAndRemoveLines(
  view: EditorView,
  range: { from: number; to: number }
) {
  // return new Promise((resolve) => {
  for (let currentLine = range.from; currentLine <= range.to; currentLine++) {
    const lineInDocument = view.state.doc.line(currentLine)

    if (lineInDocument.from === lineInDocument.to) continue
    view.dispatch({
      effects: addHighlight.of({
        from: lineInDocument.from,
        to: lineInDocument.to,
      }),
    })
  }

  const startingPosition = view.state.doc.line(range.from).from
  setTimeout(() => {
    for (let currentLine = range.from; currentLine <= range.to; currentLine++) {
      const lineInDocument = view.state.doc.line(currentLine)

      console.log('LINEFROM TO', lineInDocument.from, lineInDocument.to)
      view.dispatch({
        changes: {
          from: startingPosition,
          to: lineInDocument.to,
          insert: '',
        },
      })
    }
    // resolve();
  }, 500)
  // });
}

export function removeLineContent(
  view: EditorView,
  { line }: { line: number }
): Promise<void> {
  return new Promise((resolve) => {
    const lineObj = view.state.doc.line(line)
    let from = lineObj.from
    let to = lineObj.to

    let insert = ''
    if (line < view.state.doc.lines) {
      to += 1
      insert = '\n'
    }

    view.dispatch({
      changes: { from, to, insert: insert },
    })
    resolve()
  })
}
