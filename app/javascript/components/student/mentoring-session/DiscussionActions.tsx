import React from 'react'
import { DiscussionLinks, MentorDiscussion } from '@/components/types'
import { FinishButton } from './FinishButton'
import GraphicalIcon from '@/components/common/GraphicalIcon'

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
      className="btn-xs btn-enhanced finish-button"
    >
      <div className="--hint">End discussion</div>
    </FinishButton>
  )
}
