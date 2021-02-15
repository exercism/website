import React, { useCallback, useRef, useEffect, useContext } from 'react'
import {
  MarkdownEditor,
  MarkdownEditorHandle,
} from '../../common/MarkdownEditor'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { Loading } from '../../common/Loading'
import { useMutation, queryCache } from 'react-query'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { PostsContext } from './DiscussionContext'
import { DiscussionPostProps } from './DiscussionPost'
import { typecheck } from '../../../utils/typecheck'

const DEFAULT_ERROR = new Error('Unable to save post')

type ComponentProps = {
  endpoint: string
  method: 'POST' | 'PATCH'
  onSuccess?: () => void
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
  onSuccess = () => {},
  contextId,
  value = '',
}: ComponentProps): JSX.Element => {
  const editorRef = useRef<MarkdownEditorHandle | null>(null)
  const isMountedRef = useIsMounted()
  const { cacheKey } = useContext(PostsContext)
  const [mutation, { status, error }] = useMutation<
    DiscussionPostProps | undefined
  >(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: method,
        body: JSON.stringify({ content: editorRef.current?.value() }),
        isMountedRef: isMountedRef,
      }).then((json) => {
        if (!json) {
          return
        }

        return typecheck<DiscussionPostProps>(json, 'post')
      })
    },
    {
      onSettled: () => queryCache.invalidateQueries(cacheKey),
      onSuccess: (data) => {
        if (!data) {
          return
        }

        const oldData =
          queryCache.getQueryData<DiscussionPostProps[]>(cacheKey) || []

        queryCache.setQueryData(
          [cacheKey],
          oldData.map((post) => {
            return post.id === data.id ? data : post
          })
        )

        onSuccess()
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
    <>
      <form onSubmit={handleSubmit} className="c-markdown-editor">
        <MarkdownEditor
          contextId={contextId}
          value={value}
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
      </form>
      {status === 'loading' ? <Loading /> : null}
      <ErrorBoundary FallbackComponent={ErrorFallback} resetKeys={[status]}>
        <ErrorMessage error={error} />
      </ErrorBoundary>
    </>
  )
}
