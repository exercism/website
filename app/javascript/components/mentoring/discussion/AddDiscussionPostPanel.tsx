import React, { useContext } from 'react'
import { TabsContext } from '../Session'
import { AddDiscussionPost } from './AddDiscussionPost'
import { NewMessageAlert } from './NewMessageAlert'
import { MentorDiscussion as Discussion } from '../../types'

type Links = {
  mentoringDocs: string
}

export const AddDiscussionPostPanel = ({
  discussion,
  links,
}: {
  discussion: Discussion
  links: Links
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
      >
        <div className="note">
          Check out our{' '}
          <a href={links.mentoringDocs} target="_blank" rel="noreferrer">
            mentoring docs
          </a>{' '}
          and be the best mentor you can be.
        </div>
      </AddDiscussionPost>
    </section>
  )
}
