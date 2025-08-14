import React from 'react'
import { DiscussionPostList } from '../../mentoring/discussion/DiscussionPostList'
import { AddDiscussionPost } from '../../mentoring/discussion/AddDiscussionPost'
import { NewMessageAlert } from '../../mentoring/discussion/NewMessageAlert'
import { PostsWrapper } from '../../mentoring/discussion/PostsContext'
import { MentorInfo } from './MentorInfo'
import {
  MentorDiscussion,
  Iteration,
  MentoringSessionDonation,
} from '../../types'
import { Mentor } from '../MentoringSession'
import { GraphicalIcon } from '../../common'
import { FinishButton } from './FinishButton'
import { QueryStatus } from '@tanstack/react-query'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type Links = {
  exercise: string
}

export const DiscussionInfo = ({
  discussion,
  mentor,
  userHandle,
  iterations,
  onIterationScroll,
  links,
  status,
  donation,
}: {
  discussion: MentorDiscussion
  mentor: Mentor
  userHandle: string
  iterations: readonly Iteration[]
  onIterationScroll: (iteration: Iteration) => void
  links: DiscussionActionsLinks
  status: QueryStatus
  donation: MentoringSessionDonation
}): JSX.Element => {
  const timedOut =
    discussion.finishedBy &&
    ['mentor_timed_out', 'student_timed_out'].includes(discussion.finishedBy)

  const timedOutStatus =
    discussion.status &&
    ['mentor_timed_out', 'student_timed_out'].includes(discussion.status)

  return (
    <PostsWrapper discussion={discussion}>
      <div id="panel-discussion">
        <MentorInfo mentor={mentor} />
        <div className="c-discussion-timeline">
          <DiscussionPostList
            iterations={iterations}
            userIsStudent={true}
            discussionUuid={discussion.uuid}
            userHandle={userHandle}
            onIterationScroll={onIterationScroll}
            status={status}
          />
          {discussion.status === 'mentor_finished' && (
            <DiscussionMentorFinished
              discussion={discussion}
              mentor={mentor}
              links={links}
              donation={donation}
            />
          )}
          {timedOut && timedOutStatus && (
            <DiscussionMentorTimedOut
              discussion={discussion}
              donation={donation}
              mentor={mentor}
              links={links}
            />
          )}
        </div>
      </div>
      <section className="comment-section --comment">
        <NewMessageAlert />
        <AddDiscussionPost discussion={discussion} />
      </section>
    </PostsWrapper>
  )
}

function DiscussionMentorFinished({
  mentor,
  discussion,
  links,
  donation,
}: {
  mentor: Mentor
  discussion: MentorDiscussion
  links: DiscussionActionsLinks
  donation: MentoringSessionDonation
}) {
  const { t } = useAppTranslation('components/student/mentoring-session')
  return (
    <div className="student-review timeline-entry">
      <GraphicalIcon
        icon="completed-check-circle"
        className="timeline-marker"
      />
      <div className="--details timeline-content">
        <h3>
          {t('discussionInfo.endedThisDiscussion', {
            mentorHandle: mentor.handle,
          })}
        </h3>
        <p>
          <strong>
            {t('discussionInfo.itsTimeToReviewMentoring', {
              mentorHandle: mentor.handle,
            })}
          </strong>
          {t('discussionInfo.youllBeAbleToLeaveFeedback')}
        </p>
        <FinishButton
          discussion={discussion}
          links={links}
          donation={donation}
          className="btn-primary btn-s"
        >
          {t('discussionInfo.reviewFinishDiscussion')}
        </FinishButton>
      </div>
    </div>
  )
}

function DiscussionMentorTimedOut({
  mentor,
  discussion,
  links,
  donation,
}: {
  mentor: Mentor
  discussion: MentorDiscussion
  links: DiscussionActionsLinks
  donation: MentoringSessionDonation
}) {
  const { t } = useAppTranslation('components/student/mentoring-session')
  return (
    <div className="student-review timeline-entry">
      <GraphicalIcon
        icon="completed-check-circle"
        className="timeline-marker"
      />
      <div className="--details timeline-content">
        <h3>{t('discussionInfo.thisDiscussionTimedOut')}</h3>
        <p>
          <strong>
            {t('discussionInfo.itsTimeToReviewMentoring', {
              mentorHandle: mentor.handle,
            })}
          </strong>
          {t('discussionInfo.youllBeAbleToLeaveFeedback')}
        </p>
        <FinishButton
          discussion={discussion}
          links={links}
          donation={donation}
          className="btn-primary btn-s"
        >
          {t('discussionInfo.reviewDiscussion')}
        </FinishButton>
      </div>
    </div>
  )
}
