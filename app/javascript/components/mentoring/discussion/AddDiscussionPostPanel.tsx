import React, { useContext } from 'react'
import { TabsContext } from '../Session'
import { AddDiscussionPost } from './AddDiscussionPost'
import { NewMessageAlert } from './NewMessageAlert'
import { MentorSessionDiscussion as Discussion } from '../../types'

export const AddDiscussionPostPanel = ({
  discussion,
}: {
  discussion: Discussion
}): JSX.Element => {
  const { switchToTab } = useContext(TabsContext)

  return (
    <section className="comment-section --comment">
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
