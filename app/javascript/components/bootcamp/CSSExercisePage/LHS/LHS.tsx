import React, { useEffect } from 'react'
import { CSSEditor } from './CSSEditor'
import { HTMLEditor } from './HTMLEditor'
import { ControlButtons } from './ControlButtons'
import { EditorCode } from '../hooks/useSetupEditors'

export function LHS({
  editorCode,
  getEditorValues,
}: {
  editorCode: EditorCode
  getEditorValues: () => { cssValue: string; htmlValue: string }
}) {
  useEffect(() => {
    console.log('editorCode', editorCode)
  }, [])
  return (
    <div className="page-body-lhs">
      <HTMLEditor defaultCode={editorCode.htmlEditorContent} />
      <CSSEditor defaultCode={editorCode.cssEditorContent} />
      <ControlButtons getEditorValues={getEditorValues} />
    </div>
  )
}
