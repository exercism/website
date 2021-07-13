import React, { useState, useCallback, useContext } from 'react'
import { useIsMounted } from 'use-is-mounted'
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
  const isMountedRef = useIsMounted()
  const { cacheKey } = useContext(PostsContext)

  const [mutation, { status: editStatus, error: editError }] = useMutation<
    DiscussionPostProps | undefined,
    unknown,
    MutationAction
  >(
    (action) => {
      return sendRequest({
        endpoint: action === 'update' ? post.links.edit : post.links.delete,
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
