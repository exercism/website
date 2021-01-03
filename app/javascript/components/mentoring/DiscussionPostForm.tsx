import React, { useCallback, useRef, useState } from 'react'
import { MarkdownEditor, MarkdownEditorHandle } from '../common/MarkdownEditor'
import { sendRequest, APIError } from '../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { Loading } from '../common/Loading'

export const DiscussionPostForm = ({
  endpoint,
  method,
  onSuccess,
  contextId,
  value = '',
}: {
  endpoint: string
  method: 'POST' | 'PATCH'
  onSuccess: () => void
  contextId: string
  value?: string
}): JSX.Element => {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<APIError | null>(null)
  const editorRef = useRef<MarkdownEditorHandle | null>(null)
  const isMountedRef = useIsMounted()

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      setIsLoading(true)

      sendRequest({
        endpoint: endpoint,
        body: JSON.stringify({ content: editorRef.current?.getValue() }),
        method: method,
        isMountedRef: isMountedRef,
      })
        .then(onSuccess)
        .catch((err) => {
          if (err instanceof Response) {
            err.json().then((res: any) => {
              setError(res.error)
            })
          }
        })
        .finally(() => {
          if (!isMountedRef.current) {
            return
          }

          setIsLoading(false)
        })
    },
    [endpoint, isMountedRef, method, onSuccess]
  )

  const handleEditorMount = useCallback(
    (editor: MarkdownEditorHandle) => {
      editorRef.current = editor
    },
    [editorRef]
  )

  return (
    <div>
      <form onSubmit={handleSubmit}>
        <MarkdownEditor
          contextId={contextId}
          value={value}
          editorDidMount={handleEditorMount}
        />
        <button type="submit" disabled={isLoading}>
          Send
        </button>
      </form>
      {isLoading ? <Loading /> : null}
      {error ? <p>{error.message}</p> : null}
    </div>
  )
}
