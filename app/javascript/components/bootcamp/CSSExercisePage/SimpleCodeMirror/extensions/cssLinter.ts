import { CSSLint } from 'csslint'
import { linter as cmLinter, Diagnostic } from '@codemirror/lint'

export const cssLinter = cmLinter((view) => {
  const code = view.state.doc.toString()
  // check https://csslint.net/about.html
  const messages = CSSLint.verify(code, {
    'adjoining-classes': false,
    'box-model': false,
    'box-sizing': false,
    'compatible-vendor-prefixes': false,
    'display-property-grouping': false,
    'duplicate-background-images': false,
    'duplicate-properties': false,
    'empty-rules': false,
    errors: false,
    'fallback-colors': false,
    floats: false,
    'font-faces': false,
    'font-sizes': false,
    gradients: false,
    ids: false,
    import: false,
    important: false,
    'known-properties': false,
    'outline-none': false,
    'overqualified-elements': false,
    'qualified-headings': false,
    'regex-selectors': false,
    'rules-count': false,
    'selector-max-approaching': false,
    shorthand: false,
    'star-property-hack': false,
    'text-indent': false,
    'underscore-property-hack': false,
    'unique-headings': false,
    'universal-selector': false,
    'unqualified-attributes': false,
    'vendor-prefix': false,
    'zero-units': false,
  })

  const diagnostics: Diagnostic[] = messages.messages.map((msg) => ({
    from: view.state.doc.line(msg.line).from + msg.col - 1,
    to: view.state.doc.line(msg.line).from + msg.col,
    severity: msg.type === 'error' ? 'error' : 'warning',
    message: msg.message,
    source: msg.rule.id,
  }))

  return diagnostics
})
