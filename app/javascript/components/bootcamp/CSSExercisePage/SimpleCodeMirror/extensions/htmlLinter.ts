import { HTMLHint } from 'htmlhint'
import { linter as cmLinter, Diagnostic } from '@codemirror/lint'
import { EditorView } from 'codemirror'

export const htmlLinter = cmLinter((view) => {
  const code = view.state.doc.toString()
  const messages = HTMLHint.verify(code, {
    'tag-pair': true,
    'attr-no-duplication': true,
    'attr-unsafe-chars': true,
    'tagname-lowercase': true,
    'attr-lowercase': true,
    'id-unique': true,
    'spec-char-escape': true,
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

export const lintTooltipTheme = EditorView.theme({
  '.cm-tooltip-hover.cm-tooltip.cm-tooltip-below': {
    borderRadius: '8px',
  },

  '.cm-tooltip .cm-tooltip-lint': {
    backgroundColor: 'var(--backgroundColorF)',
    borderRadius: '8px',
    color: 'var(--textColor6)',
    border: '1px solid var(--borderColor6)',
    padding: '4px 8px',
    fontSize: '14px',
    fontFamily: 'poppins',
  },
  'span.cm-diagnosticText': {
    display: 'block',
    marginBottom: '8px',
  },
  '.cm-diagnostic.cm-diagnostic-error': {
    borderColor: '#EB5757',
  },
  '.cm-diagnostic.cm-diagnostic-warning': {
    borderColor: '#F69605',
  },
})
