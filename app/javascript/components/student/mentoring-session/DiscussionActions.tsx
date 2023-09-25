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
  links: DiscussionActionsLinks
}

export type DiscussionActionsLinks = MentoringSessionLinks & {
  exerciseMentorDiscussionUrl: string
}

export const DiscussionActions = ({
  discussion,
  links,
  donation,
}: DiscussionActionsProps): JSX.Element => {
  const timedOut =
    discussion.finishedBy &&
    ['mentor_timed_out', 'student_timed_out'].includes(discussion.finishedBy)

  return discussion.isFinished || discussion.status === 'mentor_finished' ? (
    <div className="finished">
      <GraphicalIcon icon="completed-check-circle" />
      Ended
    </div>
  ) : (
    <FinishButton
      discussion={discussion}
      links={links}
      donation={donation}
      className={`btn-xs ${
        timedOut ? 'btn-primary' : 'btn-enhanced'
      } finish-button`}
    >
      <div className="--hint">
        {timedOut ? 'Review discussion' : 'End discussion'}
      </div>
    </FinishButton>
  )
}
