import { EditorView } from '@codemirror/view'
import { breakpointState } from './extensions/breakpoint'

export function getBreakpointLines(view: EditorView | null): number[] {
  if (!view) return []
  const breakpoints = view.state.field(breakpointState)
  const lines: number[] = []

  breakpoints.between(0, view.state.doc.length, (from) => {
    const line = view.state.doc.lineAt(from).number
    lines.push(line)
  })

  return lines
}
