import React, { useRef, useCallback } from 'react'
import { Iteration, Discussion, MentoringRequest } from '../Session'
import { useIsMounted } from 'use-is-mounted'
import { sendRequest } from '../../../utils/send-request'
import { typecheck } from '../../../utils/typecheck'
import { useMutation } from 'react-query'
import {
  MarkdownEditor,
  MarkdownEditorHandle,
} from '../../common/MarkdownEditor'
import { Loading } from '../../common'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to start discussion')

const ErrorMessage = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

const ErrorFallback = ({ error }: { error: Error }) => {
  return <p>{error.message}</p>
}

export const StartDiscussionPanel = ({
  iterations,
  request,
  setDiscussion,
}: {
  iterations: readonly Iteration[]
  request: MentoringRequest
  setDiscussion: (discussion: Discussion) => void
}): JSX.Element => {
  const lastIteration = iterations[iterations.length - 1]
  const isMountedRef = useIsMounted()
  const editorRef = useRef<MarkdownEditorHandle | null>(null)

  const handleEditorMount = useCallback(
    (editor: MarkdownEditorHandle) => {
      editorRef.current = editor
    },
    [editorRef]
  )

  const [mutation, { status, error }] = useMutation<Discussion | undefined>(
    () => {
      return sendRequest({
        endpoint: request.links.discussion,
        method: 'POST',
        body: JSON.stringify({
          mentor_request_id: request.id,
          content: editorRef.current?.value(),
          iteration_idx: lastIteration.idx,
        }),
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<Discussion>(json, 'discussion')
      })
    },
    {
      onSuccess: (discussion) => {
        if (!discussion) {
          return
        }

        setDiscussion(discussion)
      },
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <section className="comment-section">
      <form onSubmit={handleSubmit} className="c-markdown-editor">
        <MarkdownEditor
          contextId="start-discussion"
          editorDidMount={handleEditorMount}
        />
        <footer className="editor-footer">
          <button
            className="btn-small-cta"
            type="submit"
            disabled={status === 'loading'}
          >
            Send
          </button>
        </footer>
        {status === 'loading' ? <Loading /> : null}
        <ErrorBoundary FallbackComponent={ErrorFallback} resetKeys={[status]}>
          <ErrorMessage error={error} />
        </ErrorBoundary>
      </form>
    </section>
  )
}
