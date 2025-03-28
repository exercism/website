import { CSSLint } from 'csslint'
import { linter as cmLinter, Diagnostic } from '@codemirror/lint'

export const cssLinter = cmLinter((view) => {
  const code = view.state.doc.toString()
  const messages = CSSLint.verify(code)

  const diagnostics: Diagnostic[] = messages.messages.map((msg) => ({
    from: view.state.doc.line(msg.line).from + msg.col - 1,
    to: view.state.doc.line(msg.line).from + msg.col,
    severity: msg.type === 'error' ? 'error' : 'warning',
    message: msg.message,
    source: msg.rule.id,
  }))

  return diagnostics
})
