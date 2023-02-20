import React from 'react'
import { DiscussionLinks, MentorDiscussion } from '@/components/types'
import { GraphicalIcon } from '@/components/common'
import { FinishButton } from './FinishButton'

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
