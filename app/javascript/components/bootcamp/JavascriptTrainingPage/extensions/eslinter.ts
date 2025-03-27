import * as eslint from 'eslint-linter-browserify'
import { Diagnostic, linter as cmLinter } from '@codemirror/lint'

const linter = new eslint.Linter()

export const eslintLinter = cmLinter((view) => {
  const code = view.state.doc.toString()

  const messages = linter.verify(code, {
    rules: {
      'no-console': 2,
    },
  })

  const diagnostics: Diagnostic[] = messages.map((msg) => ({
    from: view.state.doc.line(msg.line).from + (msg.column - 1),
    to:
      view.state.doc.line(msg.endLine ?? msg.line).from +
      (msg.endColumn ?? msg.column - 1),
    severity: msg.severity === 2 ? 'error' : 'warning',
    message: msg.message,
    source: msg.ruleId ?? 'eslint',
  }))

  return diagnostics
})
