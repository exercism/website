import React from 'react'
import { Header } from './mentoring-dropdown/Header'
import { DiscussionList } from './mentoring-dropdown/DiscussionList'
import { MentorDiscussion } from '../types'

export type Links = {
  share: string
}

export const MentoringDropdown = ({
  hasMentorDiscussionInProgress,
  discussions,
  links,
}: {
  hasMentorDiscussionInProgress: boolean
  discussions: readonly MentorDiscussion[]
  links: Links
}): JSX.Element => {
  return (
    <div className="c-request-mentoring-dropdown">
      <Header
        hasMentorDiscussionInProgress={hasMentorDiscussionInProgress}
        shareLink={links.share}
      />
      <DiscussionList discussions={discussions} />
    </div>
  )
}
