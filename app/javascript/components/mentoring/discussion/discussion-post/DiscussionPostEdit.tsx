import React, { useState, useCallback, useContext } from 'react'
import { useIsMounted } from 'use-is-mounted'
import { PostsContext } from '../PostsContext'
import { useMutation, queryCache } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { DiscussionPostProps } from '../DiscussionPost'
import { typecheck } from '../../../../utils/typecheck'
import { MarkdownEditorForm } from '../../../common/MarkdownEditorForm'

const DEFAULT_ERROR = new Error('Unable to edit post')

type MutationAction = 'update' | 'delete'

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

  const [mutation, { status: editStatus, error: editError }] = useMutation<
    DiscussionPostProps | undefined,
    unknown,
    MutationAction
  >(
    (action) => {
      return sendRequest({
        endpoint: post.links.self,
        method: action === 'update' ? 'PATCH' : 'DELETE',
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
      onSuccess: (data, action) => {
        if (!data) {
          return
        }

        const oldData = queryCache.getQueryData<{
          posts: DiscussionPostProps[]
        }>(cacheKey) || { posts: [] }

        switch (action) {
          case 'delete': {
            queryCache.setQueryData(
              [cacheKey],
              oldData.posts.filter((post) => post.uuid !== data.uuid)
            )

            break
          }
          case 'update': {
            queryCache.setQueryData(
              [cacheKey],
              oldData.posts.map((post) => {
                return post.uuid === data.uuid ? data : post
              })
            )

            onSuccess()

            break
          }
        }
      },
    }
  )
  const handleSubmit = useCallback(() => {
    mutation('update')
  }, [mutation])
  const handleDelete = useCallback(() => {
    mutation('delete')
  }, [mutation])
  const handleCancel = useCallback(() => onCancel(), [onCancel])
  const handleChange = useCallback((value) => setValue(value), [setValue])

  return (
    <MarkdownEditorForm
      expanded
      onSubmit={handleSubmit}
      onCancel={handleCancel}
      onChange={handleChange}
      onDelete={handleDelete}
      value={value}
      status={editStatus}
      error={editError}
      defaultError={DEFAULT_ERROR}
      action="edit"
    />
  )
}
