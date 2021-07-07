import React, { useCallback, useContext } from 'react'
import { sendRequest } from '../../../utils/send-request'
import { useIsMounted } from 'use-is-mounted'
import { useMutation, queryCache } from 'react-query'
import { PostsContext } from './PostsContext'
import { DiscussionPostProps } from './DiscussionPost'
import { typecheck } from '../../../utils/typecheck'
import { MarkdownEditorForm } from '../../common/MarkdownEditorForm'

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
  const isMountedRef = useIsMounted()
  const { cacheKey } = useContext(PostsContext)
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
            return post.uuid === data.uuid ? data : post
          })
        )

        onSuccess()
      },
    }
  )

  const handleSubmit = useCallback(() => {
    mutation()
  }, [mutation])

  const handleClick = useCallback(() => {
    onClick()
  }, [onClick])

  const handleChange = useCallback(
    (value: string) => {
      onChange(value)
    },
    [onChange]
  )

  const handleCancel = useCallback(() => {
    onCancel()
  }, [onCancel])

  return (
    <MarkdownEditorForm
      onSubmit={handleSubmit}
      onClick={handleClick}
      onCancel={handleCancel}
      onChange={handleChange}
      contextId={contextId}
      value={value}
      expanded={expanded}
      status={status}
      error={error}
      defaultError={DEFAULT_ERROR}
    />
  )
}
