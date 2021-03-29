import React from 'react'
import { MentoringDropdown } from '../MentoringDropdown'
import { MentorDiscussion } from '../../types'
import { ComboButton } from '../../common/ComboButton'

type Links = {
  requestMentoring: string
  shareMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

export const MentoringComboButton = ({
  hasMentorDiscussionInProgress,
  hasMentorRequestPending,
  discussions,
  className = '',
  links,
}: {
  hasMentorDiscussionInProgress: boolean
  hasMentorRequestPending: boolean
  discussions: readonly MentorDiscussion[]
  className?: string
  links: Links
}): JSX.Element => {
  return (
    <ComboButton className={className}>
      <ComboButton.EditorSegment>
        {hasMentorDiscussionInProgress && links.inProgressDiscussion ? (
          <a href={links.inProgressDiscussion}>Continue mentoring</a>
        ) : hasMentorRequestPending ? (
          <a href={links.pendingMentorRequest}>View mentoring request</a>
        ) : (
          <a href={links.requestMentoring}>Request mentoring</a>
        )}
      </ComboButton.EditorSegment>
      <ComboButton.DropdownSegment>
        <MentoringDropdown
          hasMentorDiscussionInProgress={hasMentorDiscussionInProgress}
          discussions={discussions}
          links={{ share: links.shareMentoring }}
        />
      </ComboButton.DropdownSegment>
    </ComboButton>
  )
}
