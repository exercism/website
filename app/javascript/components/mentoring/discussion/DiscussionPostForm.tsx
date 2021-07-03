import React, { useCallback, useContext, useState, useEffect } from 'react'
import {
  MarkdownEditor,
  MarkdownEditorHandle,
} from '../../common/MarkdownEditor'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { useMutation, queryCache } from 'react-query'
import { ErrorBoundary, useErrorHandler } from '../../ErrorBoundary'
import { PostsContext } from './PostsContext'
import { DiscussionPostProps } from './DiscussionPost'
import { typecheck } from '../../../utils/typecheck'
import { FormFooter } from './discussion-post-form/FormFooter'

const DEFAULT_ERROR = new Error('Unable to save post')

type ComponentProps = {
  endpoint: string
  method: 'POST' | 'PATCH'
  onSuccess?: () => void
  onCancel?: () => void
  onClick?: () => void
  onChange?: (value: string) => void
  contextId: string
  expanded?: boolean
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
  onSuccess = () => null,
  onCancel = () => null,
  onClick = () => null,
  onChange = () => null,
  contextId,
  expanded = true,
  value = '',
}: ComponentProps): JSX.Element => {
  const [editor, setEditor] = useState<MarkdownEditorHandle | null>(null)
  const isMountedRef = useIsMounted()
  const { cacheKey } = useContext(PostsContext)
  const classNames = [
    'c-markdown-editor',
    expanded ? '--expanded' : '--compressed',
  ].filter((className) => className.length > 0)
  const [mutation, { status, error }] = useMutation<
    DiscussionPostProps | undefined
  >(
    () => {
      return sendRequest({
        endpoint: endpoint,
        method: method,
        body: JSON.stringify({ content: value }),
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

  const handleClick = useCallback(() => {
    onClick()
  }, [onClick])

  const handleChange = useCallback(
    (value: string) => {
      onChange(value)
    },
    [onChange]
  )

  const handleCancel = useCallback(
    (e) => {
      e.stopPropagation()
      onCancel()
    },
    [onCancel]
  )

  const handleEditorDidMount = useCallback((editor) => {
    setEditor(editor)
  }, [])

  useEffect(() => {
    if (!expanded || !editor) {
      return
    }

    editor.focus()
  }, [expanded, editor])

  return (
    <>
      <form
        onSubmit={handleSubmit}
        onClick={handleClick}
        className={classNames.join(' ')}
        data-testid="markdown-editor"
      >
        <MarkdownEditor
          contextId={contextId}
          value={value}
          onChange={handleChange}
          editorDidMount={handleEditorDidMount}
        />
        {expanded ? (
          <FormFooter onCancel={handleCancel} value={value} status={status} />
        ) : null}
      </form>
      <ErrorBoundary FallbackComponent={ErrorFallback} resetKeys={[status]}>
        <ErrorMessage error={error} />
      </ErrorBoundary>
    </>
  )
}
