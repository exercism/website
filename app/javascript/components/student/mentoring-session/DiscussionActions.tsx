import React from 'react'
import { FinishButton } from './FinishButton'
import { MentorDiscussion } from '../../types'
import { GraphicalIcon } from '../../common'

type Links = {
  exercise: string
}

export const DiscussionActions = ({
  discussion,
  links,
}: {
  discussion: MentorDiscussion
  links: Links
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
      className="btn-xs btn-enhanced finish-button"
    >
      <div className="--hint">End discussion</div>
    </FinishButton>
  )
}
