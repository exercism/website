import React from 'react'
import { MentorDiscussion } from '../../../types'
import { Avatar, ExerciseIcon, GraphicalIcon } from '../../../common'
import { fromNow } from '../../../../utils/time'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const RateMentorStep = ({
  discussion,
  onHappy,
  onSatisfied,
  onUnhappy,
}: {
  discussion: MentorDiscussion
  onHappy: () => void
  onSatisfied: () => void
  onUnhappy: () => void
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/modals/student/finish-mentor-discussion-modal'
  )
  const timedOut =
    discussion.finishedBy &&
    ['mentor_timed_out', 'student_timed_out'].includes(discussion.finishedBy)

  return (
    <section id="a11y-finish-mentor-discussion" className="rate-step">
      <h2>{t('rateMentorStep.reviewDiscussion')}</h2>
      <div className="container">
        <div className="lhs">
          {(discussion.finishedBy === 'mentor' ||
            discussion.finishedBy === 'mentor_timed_out' ||
            discussion.finishedBy === 'student_timed_out') &&
          discussion.finishedAt !== undefined ? (
            <div className="finished-info">
              <Avatar
                src={discussion.mentor.avatarUrl}
                handle={discussion.mentor.handle}
              />
              <div className="info">
                <div className="mentor">
                  {timedOut
                    ? t('rateMentorStep.yourDiscussionTimedOut')
                    : t('rateMentorStep.mentorFinishedMentoring', {
                        mentorHandle: discussion.mentor.handle,
                      })}
                </div>
                <div className="exercise">
                  <ExerciseIcon iconUrl={discussion.exercise.iconUrl} />
                  <strong>{discussion.exercise.title}</strong> in{' '}
                  {discussion.track.title}
                </div>
              </div>
              <time>{fromNow(discussion.finishedAt)}</time>
            </div>
          ) : null}
          <p className="explanation">
            {t('rateMentorStep.feedbackRequest', {
              mentorHandle: discussion.mentor.handle,
            })}
          </p>
          <div className="buttons-section">
            <h3>
              {t('rateMentorStep.howWasDiscussion', {
                mentorHandle: discussion.mentor.handle,
              })}
            </h3>
            <div className="buttons">
              <button type="button" onClick={onUnhappy} className="sad">
                <GraphicalIcon icon="sad-face" />
                {t('rateMentorStep.problematic')}
              </button>
              <button type="button" onClick={onSatisfied} className="neutral">
                <GraphicalIcon icon="neutral-face" />
                {t('rateMentorStep.acceptable')}
              </button>
              <button type="button" onClick={onHappy} className="happy">
                <GraphicalIcon icon="happy-face" />
                {t('rateMentorStep.itWasGood')}
              </button>
            </div>
          </div>
        </div>
        <div className="rhs">
          <Avatar
            src={discussion.mentor.avatarUrl}
            handle={discussion.mentor.handle}
          />
        </div>
      </div>
    </section>
  )
}
