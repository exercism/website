import React from 'react'
import { FinishButton } from './FinishButton'
import { DonationLinks, MentorDiscussion } from '../../types'
import { GraphicalIcon } from '../../common'

export type DiscussionLinks = {
  exercise: string
  donation: DonationLinks
}

export const DiscussionActions = ({
  discussion,
  links,
}: {
  discussion: MentorDiscussion
  links: DiscussionLinks
}): JSX.Element => {
  return discussion.isFinished || discussion.status === 'mentor_finished' ? (
    <div className="finished">
      <GraphicalIcon icon="completed-check-circle" />
      Ended
    </div>
  ) : (
    <FinishButton
      discussion={discussion}
      links={links}
      className="btn-keyboard-shortcut finish-button"
    >
      <div className="--hint">End discussion</div>
    </FinishButton>
  )
}
