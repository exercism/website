import { HTMLHint } from 'htmlhint'
import { linter as cmLinter, Diagnostic } from '@codemirror/lint'

export const htmlLinter = cmLinter((view) => {
  const code = view.state.doc.toString()
  const messages = HTMLHint.verify(code, {
    'tagname-lowercase': true,
    'attr-value-double-quotes': true,
  })

  const diagnostics: Diagnostic[] = messages.map((msg) => ({
    from: view.state.doc.line(msg.line).from + msg.col - 1,
    to: view.state.doc.line(msg.line).from + msg.col,
    severity: msg.type === 'error' ? 'error' : 'warning',
    message: msg.message,
    source: msg.rule.id,
  }))

  return diagnostics
})
