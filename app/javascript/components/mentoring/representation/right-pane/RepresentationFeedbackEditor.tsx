import React, {
  FocusEventHandler,
  MouseEventHandler,
  useCallback,
  useEffect,
  useState,
} from 'react'
import {
  MarkdownEditorHandle,
  default as MarkdownEditor,
} from '@/components/common/MarkdownEditor'
import { PrimaryButton } from '../common/PrimaryButton'

export function RepresentationFeedbackEditor({
  onChange,
  value,
  expanded,
  onFocus,
  onBlur,
  onPreviewClick,
}: {
  onChange: (value: string) => void
  onFocus: MouseEventHandler<HTMLDivElement>
  onBlur: FocusEventHandler<HTMLDivElement>
  value: string
  expanded: boolean
  onPreviewClick: () => void
}): JSX.Element {
  const [editor, setEditor] = useState<MarkdownEditorHandle | null>(null)

  const handleEditorDidMount = useCallback((editor) => {
    setEditor(editor)
  }, [])

  useEffect(() => {
    if (!expanded) {
      return
    }

    editor?.focus()
  }, [editor, expanded])

  return (
    <div
      id="markdown-editor"
      onClick={onFocus}
      onBlur={onBlur}
      className={`c-markdown-editor ${
        expanded ? '--expanded' : '--compressed'
      }`}
    >
      <MarkdownEditor
        onChange={onChange}
        editorDidMount={handleEditorDidMount}
        value={value}
      />

      <div className="editor-footer">
        <PrimaryButton
          disabled={!/[a-zA-Z0-9]/.test(value)}
          className="px-[18px] py-[12px] "
          onClick={onPreviewClick}
        >
          Preview & Submit
        </PrimaryButton>
      </div>
    </div>
  )
}
