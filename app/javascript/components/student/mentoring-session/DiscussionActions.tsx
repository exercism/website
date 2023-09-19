import React from 'react'
import {
  MentorDiscussion,
  MentoringSessionDonation,
  MentoringSessionLinks,
} from '@/components/types'
import { FinishButton } from './FinishButton'
import GraphicalIcon from '@/components/common/GraphicalIcon'

type DiscussionActionsProps = {
  discussion: MentorDiscussion
  donation: MentoringSessionDonation
  links: MentoringSessionLinks
}

export const DiscussionActions = ({
  discussion,
  links,
  donation,
}: DiscussionActionsProps): JSX.Element => {
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
      donation={donation}
    >
      <div className="--hint">End discussion</div>
    </FinishButton>
  )
}
