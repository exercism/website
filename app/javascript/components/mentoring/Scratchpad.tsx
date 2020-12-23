import React, { useCallback, useState, useRef } from 'react'
import { MarkdownEditor, MarkdownEditorHandle } from '../common/MarkdownEditor'
import { sendPostRequest } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'

export const Scratchpad = ({
  endpoint,
  discussionId,
}: {
  endpoint: string
  discussionId: number
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const editorRef = useRef<MarkdownEditorHandle | null>()
  const [saved, setSaved] = useState(false)

  const handleEditorDidMount = useCallback((editor: MarkdownEditorHandle) => {
    editorRef.current = editor
  }, [])

  const handleChange = useCallback(() => {
    if (!saved) {
      return
    }

    setSaved(false)
  }, [saved])

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      if (!editorRef.current) {
        return
      }

      sendPostRequest({
        endpoint: endpoint,
        body: { content_markdown: editorRef.current?.getValue() },
        isMountedRef: isMountedRef,
      }).then((json: any) => {
        if (!json) {
          return
        }

        setSaved(true)
      })
    },
    [endpoint, isMountedRef]
  )

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <MarkdownEditor
          editorDidMount={handleEditorDidMount}
          onChange={handleChange}
          contextId={`scratchpad-${discussionId}`}
        />
        <button type="submit">Save</button>
      </form>
      {saved ? null : <p>Unsaved</p>}
    </div>
  )
}
