import React, { useCallback, useRef, useEffect } from 'react'
import {
  MarkdownEditor,
  MarkdownEditorHandle,
} from '../../common/MarkdownEditor'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { Loading } from '../../common/Loading'
import { useMutation } from 'react-query'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to save post')

type ComponentProps = {
  endpoint: string
  method: 'POST' | 'PATCH'
  onSuccess: () => void
  contextId: string
  value?: string
}

const ErrorMessage = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return <p>{error.message}</p>
}

export const DiscussionPostForm = ({
  endpoint,
  method,
  onSuccess,
  contextId,
  value = '',
}: ComponentProps): JSX.Element => {
  const editorRef = useRef<MarkdownEditorHandle | null>(null)
  const isMountedRef = useIsMounted()
  const [mutation, { status, error }] = useMutation(() => {
    return sendRequest({
      endpoint: endpoint,
      method: method,
      body: JSON.stringify({ content: editorRef.current?.value() }),
      isMountedRef: isMountedRef,
    }).then(onSuccess)
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const handleEditorMount = useCallback(
    (editor: MarkdownEditorHandle) => {
      editorRef.current = editor
    },
    [editorRef]
  )

  useEffect(() => {
    if (!editorRef.current) {
      return
    }

    editorRef.current.value(value)
  }, [value])

  return (
    <div className="comment-form">
      <form onSubmit={handleSubmit}>
        <MarkdownEditor
          contextId={contextId}
          value={value}
          editorDidMount={handleEditorMount}
        />
        <footer className="comment-form-footer">
          <button
            className="btn-small-cta"
            type="submit"
            disabled={status === 'loading'}
          >
            Send
          </button>
        </footer>
      </form>
      {status === 'loading' ? <Loading /> : null}
      <ErrorBoundary FallbackComponent={ErrorFallback} resetKeys={[status]}>
        <ErrorMessage error={error} />
      </ErrorBoundary>
    </div>
  )
}
