import React, { useState, useCallback, useContext } from 'react'
import { PostsContext } from '../PostsContext'
import { useMutation, queryCache } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { DiscussionPostProps } from '../DiscussionPost'
import { typecheck } from '../../../../utils/typecheck'
import { MarkdownEditorForm } from '../../../common/MarkdownEditorForm'
import { Avatar } from '../../../common/Avatar'

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
  const { cacheKey } = useContext(PostsContext)

  const [mutation, { status: editStatus, error: editError }] = useMutation<
    DiscussionPostProps,
    unknown,
    MutationAction
  >(
    (action) => {
      const endpoint = action === 'update' ? post.links.edit : post.links.delete

      if (!endpoint) {
        throw `No endpoint for action ${action}`
      }

      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: action === 'update' ? 'PATCH' : 'DELETE',
        body: JSON.stringify({ content: value }),
      })

      return fetch.then((json) => typecheck<DiscussionPostProps>(json, 'post'))
    },
    {
      onSuccess: (data, action) => {
        switch (action) {
          case 'delete': {
            queryCache.setQueryData<{ posts: DiscussionPostProps[] }>(
              [cacheKey],
              (oldData) => {
                if (!oldData) {
                  return { posts: [] }
                }

                return {
                  posts: oldData.posts.filter(
                    (post) => post.uuid !== data.uuid
                  ),
                }
              }
            )

            break
          }
          case 'update': {
            queryCache.setQueryData<{ posts: DiscussionPostProps[] }>(
              [cacheKey],
              (oldData) => {
                if (!oldData) {
                  return { posts: [post] }
                }

                return {
                  posts: oldData.posts.map((post) => {
                    return post.uuid === data.uuid ? data : post
                  }),
                }
              }
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
    <div className={`post timeline-entry`}>
      <Avatar
        handle={post.authorHandle}
        src={post.authorAvatarUrl}
        className="timeline-marker"
      />
      <div className="timeline-content">
        <header className="timeline-entry-header">
          <div className="author">{post.authorHandle}</div>
        </header>

        <MarkdownEditorForm
          expanded
          onSubmit={handleSubmit}
          onCancel={handleCancel}
          onChange={handleChange}
          onDelete={post.links.delete ? handleDelete : undefined}
          value={value}
          status={editStatus}
          error={editError}
          defaultError={DEFAULT_ERROR}
          action="edit"
        />
      </div>
    </div>
  )
}
