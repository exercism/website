import React from 'react'
import { MentoringDropdown } from './MentoringDropdown'
import { MentorDiscussion, SolutionMentoringStatus } from '../types'
import {
  ComboButton,
  PrimarySegment,
  DropdownSegment,
} from '../common/ComboButton'

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
      <PrimarySegment>
        {mentoringStatus === 'in_progress' && links.inProgressDiscussion ? (
          <a href={links.inProgressDiscussion}>Continue code review</a>
        ) : mentoringStatus === 'requested' ? (
          <a href={links.pendingMentorRequest}>View request</a>
        ) : (
          <a href={links.requestMentoring}>Submit for Code Review</a>
        )}
      </PrimarySegment>
      <DropdownSegment>
        <MentoringDropdown
          mentoringStatus={mentoringStatus}
          discussions={discussions}
          links={{ share: links.shareMentoring }}
        />
      </DropdownSegment>
    </ComboButton>
  )
}
