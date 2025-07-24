import React from 'react'
import {
  MentorDiscussion,
  MentoringSessionDonation,
  MentoringSessionLinks,
} from '@/components/types'
import { FinishButton } from './FinishButton'
import GraphicalIcon from '@/components/common/GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/student/mentoring-session')
  const timedOut =
    discussion.finishedBy &&
    ['mentor_timed_out', 'student_timed_out'].includes(discussion.finishedBy)

  return discussion.isFinished || discussion.status === 'mentor_finished' ? (
    <div className="finished">
      <GraphicalIcon icon="completed-check-circle" />
      {t('discussionActions.ended')}
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
        {timedOut
          ? t('discussionActions.reviewDiscussion')
          : t('discussionActions.endDiscussion')}
      </div>
    </FinishButton>
  )
}
