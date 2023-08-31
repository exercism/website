import React, { useCallback, useContext, useMemo, useState } from 'react'
import { PostsContext } from './PostsContext'
import { DiscussionPostProps } from './DiscussionPost'
import { MentorDiscussion } from '../../types'
import { NewListItemForm } from '../../common/NewListItemForm'
import { useQueryClient } from '@tanstack/react-query'

const DEFAULT_ERROR = new Error('Unable to save post')

export const AddDiscussionPostForm = ({
  discussion,
  onSuccess,
}: {
  discussion: MentorDiscussion
  onSuccess: () => void
}): JSX.Element => {
  const queryClient = useQueryClient()
  const contextId = useMemo(() => `${discussion.uuid}_new_post`, [discussion])
  const [expanded, setExpanded] = useState(false)
  const { cacheKey } = useContext(PostsContext)

  const handleSuccess = useCallback(
    (post: DiscussionPostProps) => {
      queryClient.setQueryData<{ items: DiscussionPostProps[] }>(
        [cacheKey],
        (oldData) => {
          if (!oldData) {
            return { items: [post] }
          }

          return { items: [...oldData.items, post] }
        }
      )

      setExpanded(false)
      onSuccess()
    },
    [cacheKey, onSuccess, queryClient]
  )

  const handleExpanded = useCallback(() => {
    setExpanded(true)
  }, [])

  const handleCompressed = useCallback(() => {
    setExpanded(false)
  }, [])

  return (
    <NewListItemForm<DiscussionPostProps>
      endpoint={discussion.links.posts}
      expanded={expanded}
      contextId={contextId}
      onSuccess={handleSuccess}
      onExpanded={handleExpanded}
      onCompressed={handleCompressed}
      defaultError={DEFAULT_ERROR}
    />
  )
}
