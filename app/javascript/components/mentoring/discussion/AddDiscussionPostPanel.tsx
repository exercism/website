import React, { useContext } from 'react'
import { Discussion, TabsContext } from '../Solution'
import { AddDiscussionPost } from './AddDiscussionPost'
import { NewMessageAlert } from './NewMessageAlert'

export const AddDiscussionPostPanel = ({
  discussion,
}: {
  discussion: Discussion
}): JSX.Element => {
  const { switchToTab } = useContext(TabsContext)

  return (
    <section className="comment-section">
      <NewMessageAlert
        onClick={() => {
          switchToTab('discussion')
        }}
      />
      <AddDiscussionPost
        isFinished={discussion.isFinished}
        endpoint={discussion.links.posts}
        onSuccess={() => {
          switchToTab('discussion')
        }}
        contextId={`${discussion.id}_new_post`}
      />
    </section>
  )
}
