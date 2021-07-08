import React, { useState, useCallback, useContext } from 'react'
import { useIsMounted } from 'use-is-mounted'
import { PostsContext } from '../PostsContext'
import { useMutation, queryCache } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { DiscussionPostProps } from '../DiscussionPost'
import { typecheck } from '../../../../utils/typecheck'
import { MarkdownEditorForm } from '../../../common/MarkdownEditorForm'

const DEFAULT_ERROR = new Error('Unable to edit post')

export const DiscussionPostEdit = ({
  post,
  onSuccess,
  onCancel,
}: {
  post: DiscussionPostProps
  onSuccess: () => void
  onCancel: () => void
}): JSX.Element => {
  const [value, setValue] = useState(post.contentMarkdown)
  const isMountedRef = useIsMounted()
  const { cacheKey } = useContext(PostsContext)

  const [mutation, { status, error }] = useMutation<
    DiscussionPostProps | undefined
  >(
    () => {
      return sendRequest({
        endpoint: post.links.update,
        method: 'PATCH',
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
  const handleCancel = useCallback(() => onCancel(), [onCancel])
  const handleChange = useCallback((value) => setValue(value), [setValue])

  return (
    <MarkdownEditorForm
      expanded
      onSubmit={handleSubmit}
      onCancel={handleCancel}
      onChange={handleChange}
      value={value}
      status={status}
      error={error}
      defaultError={DEFAULT_ERROR}
      action="edit"
    />
  )
}
