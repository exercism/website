import React, { useContext } from 'react'
import { TabsContext } from '../Session'
import { AddDiscussionPost } from './AddDiscussionPost'
import { NewMessageAlert } from './NewMessageAlert'
import { MentorDiscussion as Discussion } from '../../types'

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
        discussion={discussion}
        onSuccess={() => {
          switchToTab('discussion')
        }}
      />
    </section>
  )
}
