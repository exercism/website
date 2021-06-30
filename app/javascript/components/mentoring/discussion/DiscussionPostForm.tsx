import React, { useCallback, useRef, useEffect, useContext } from 'react'
import {
  MarkdownEditor,
  MarkdownEditorHandle,
} from '../../common/MarkdownEditor'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { Loading, GraphicalIcon } from '../../common'
import { useMutation, queryCache } from 'react-query'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { PostsContext } from './PostsContext'
import { DiscussionPostProps } from './DiscussionPost'
import { typecheck } from '../../../utils/typecheck'

const DEFAULT_ERROR = new Error('Unable to save post')

type ComponentProps = {
  endpoint: string
  method: 'POST' | 'PATCH'
  onSuccess?: () => void
  onCancel?: () => void
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
  onCancel = () => {},
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

        const oldData = queryCache.getQueryData<{
          posts: DiscussionPostProps[]
        }>(cacheKey) || { posts: [] }

        queryCache.setQueryData(
          [cacheKey],
          oldData.posts.map((post) => {
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
      {/* TODO: Add --compressed or --expanded */}
      <form onSubmit={handleSubmit} className="c-markdown-editor --expanded">
        <MarkdownEditor
          contextId={contextId}
          value={value}
          editorDidMount={handleEditorMount}
        />
        <footer className="editor-footer">
          {/* TODO: Only one of these should show, depending on whether there is content in the text area or not */}
          <button
            className="btn-primary btn-xs"
            type="submit"
            disabled={status === 'loading'}
          >
            <GraphicalIcon icon="send" />
            <span>Send</span>
          </button>
          <button
            type="button"
            className="btn-default btn-xs"
            onClick={onCancel}
          >
            Cancel
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
