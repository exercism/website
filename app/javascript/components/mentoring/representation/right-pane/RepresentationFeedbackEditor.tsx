import React, {
  FocusEventHandler,
  MouseEventHandler,
  useCallback,
  useEffect,
  useState,
} from 'react'
import { MarkdownEditor } from '../../../common'
import { MarkdownEditorHandle } from '../../../common/MarkdownEditor'

export function RepresentationFeedbackEditor({
  onChange,
  value,
  expanded,
  onFocus,
  onBlur,
}: {
  onChange: (value: string) => void
  onFocus: MouseEventHandler<HTMLDivElement>
  onBlur: FocusEventHandler<HTMLDivElement>
  value: string
  expanded: boolean
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
    </div>
  )
}
