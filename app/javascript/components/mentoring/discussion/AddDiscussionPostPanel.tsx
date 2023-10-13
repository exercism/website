import React, { useContext } from 'react'
import { TabsContext } from '../Session'
import { AddDiscussionPost } from './AddDiscussionPost'
import { NewMessageAlert } from './NewMessageAlert'
import { MentorDiscussion as Discussion } from '../../types'
import { MentoringNote } from '../session/MentoringNote'
import { ScreenSizeContext } from '../session/ScreenSizeContext'

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

  const { isBelowLgWidth = false } = useContext(ScreenSizeContext) || {}

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
        {!isBelowLgWidth && <MentoringNote links={links} />}
      </AddDiscussionPost>
    </section>
  )
}
