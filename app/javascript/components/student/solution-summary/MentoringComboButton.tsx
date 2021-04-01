import React from 'react'
import { MentoringDropdown } from '../MentoringDropdown'
import { MentorDiscussion, SolutionMentoringStatus } from '../../types'
import { ComboButton } from '../../common/ComboButton'

type Links = {
  requestMentoring: string
  shareMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

export const MentoringComboButton = ({
  mentoringStatus,
  discussions,
  className = '',
  links,
}: {
  mentoringStatus: SolutionMentoringStatus
  discussions: readonly MentorDiscussion[]
  className?: string
  links: Links
}): JSX.Element => {
  return (
    <ComboButton className={className}>
      <ComboButton.PrimarySegment>
        {mentoringStatus === 'in_progress' && links.inProgressDiscussion ? (
          <a href={links.inProgressDiscussion}>Continue mentoring</a>
        ) : mentoringStatus === 'requested' ? (
          <a href={links.pendingMentorRequest}>View mentoring request</a>
        ) : (
          <a href={links.requestMentoring}>Request mentoring</a>
        )}
      </ComboButton.PrimarySegment>
      <ComboButton.DropdownSegment>
        <MentoringDropdown
          mentoringStatus={mentoringStatus}
          discussions={discussions}
          links={{ share: links.shareMentoring }}
        />
      </ComboButton.DropdownSegment>
    </ComboButton>
  )
}
