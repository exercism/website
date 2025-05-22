import { EditorCode } from './useSetupEditors'

export function getInitialEditorCode(code: CSSExercisePageCode): EditorCode {
  const fallbackReadonlyRanges = {
    html: code.defaultReadonlyRanges?.html || [],
    css: code.defaultReadonlyRanges?.css || [],
  }

  const fallbackCode: EditorCode = {
    htmlEditorContent: code.stub.html,
    cssEditorContent: code.stub.css,
    storedAt: new Date().toISOString(),
    readonlyRanges: fallbackReadonlyRanges,
  }

  if (!code.code) return fallbackCode

  let parsed: { html?: string; css?: string } = {}
  try {
    parsed = JSON.parse(code.code)
  } catch (error) {
    console.error('Error parsing initial code:', error)
    return fallbackCode
  }

  const html = parsed.html?.trim() || code.stub.html
  const css = parsed.css?.trim() || code.stub.css

  return {
    htmlEditorContent: html,
    cssEditorContent: css,
    storedAt: new Date().toISOString(),
    readonlyRanges: fallbackReadonlyRanges,
  }
}
