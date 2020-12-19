import React, { useCallback, useRef, useState } from 'react'
import { usePanel } from '../../hooks/use-panel'
import { MarkdownEditor, MarkdownEditorHandle } from '../common/MarkdownEditor'
import { sendPostRequest, APIError } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'

export const DiscussionPostForm = ({
  endpoint,
  contextId,
}: {
  endpoint: string
  contextId: string
}): JSX.Element | null => {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<APIError | null>(null)
  const editorRef = useRef<MarkdownEditorHandle | null>(null)
  const isMountedRef = useIsMounted()
  const {
    open,
    setOpen,
    buttonRef,
    panelRef,
    componentRef,
    styles,
    attributes,
  } = usePanel()

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      setIsLoading(true)

      sendPostRequest({
        endpoint: endpoint,
        body: { content: editorRef.current?.getValue() },
        isMountedRef: isMountedRef,
      })
        .then(() => setOpen(false))
        .catch((err) => {
          if (err instanceof Response) {
            err.json().then((res: any) => {
              setError(res.error)
            })
          }
        })
        .finally(() => setIsLoading(false))
    },
    [editorRef, endpoint, isMountedRef, setOpen]
  )

  const handleEditorMount = useCallback(
    (editor) => {
      editorRef.current = editor
    },
    [editorRef]
  )

  return (
    <div ref={componentRef}>
      <button
        ref={buttonRef}
        onClick={() => {
          setOpen(!open)
        }}
        type="button"
      >
        Add a comment
      </button>
      <div ref={panelRef} style={styles.popper} {...attributes.popper}>
        {open ? (
          <div>
            <form onSubmit={handleSubmit}>
              <MarkdownEditor
                editorDidMount={handleEditorMount}
                contextId={contextId}
              />
              <button type="submit">Send</button>
            </form>
            {isLoading ? <p>Loading...</p> : null}
            {error ? <p>{error.message}</p> : null}
          </div>
        ) : null}
      </div>
    </div>
  )
}
