import React from 'react'
import { Header } from './mentoring-dropdown/Header'
import { DiscussionList } from './mentoring-dropdown/DiscussionList'
import { MentorDiscussion, SolutionMentoringStatus } from '../types'

export type Links = {
  share: string
}

export const MentoringDropdown = ({
  mentoringStatus,
  discussions,
  links,
}: {
  mentoringStatus: SolutionMentoringStatus
  discussions: readonly MentorDiscussion[]
  links: Links
}): JSX.Element => {
  return (
    <div className="c-request-mentoring-dropdown">
      <Header mentoringStatus={mentoringStatus} shareLink={links.share} />
      <DiscussionList discussions={discussions} />
    </div>
  )
}
