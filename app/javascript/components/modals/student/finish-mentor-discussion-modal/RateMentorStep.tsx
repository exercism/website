import React from 'react'
import { MentorDiscussion } from '../../../types'
import { Avatar, ExerciseIcon, GraphicalIcon } from '../../../common'
import { fromNow } from '../../../../utils/time'

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
  const timedOut =
    discussion.finishedBy &&
    ['mentor_timed_out', 'student_timed_out'].includes(discussion.finishedBy)

  return (
    <section id="a11y-finish-mentor-discussion" className="rate-step">
      <h2>It&apos;s time to review this discussion</h2>
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
                    ? 'Your discussion timed out'
                    : `${discussion.mentor.handle} has finished mentoring you on`}
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
            To help us and our mentors understand how well we&apos;re doing,
            we&apos;d love some feedback on your discussion with{' '}
            {discussion.mentor.handle}. Good mentors will answer your questions,
            introduce you to new ideas, or encourage you to try new things.
          </p>
          <div className="buttons-section">
            <h3>How was your discussion with {discussion.mentor.handle}?</h3>
            <div className="buttons">
              <button type="button" onClick={onUnhappy} className="sad">
                <GraphicalIcon icon="sad-face" />
                Problematic
              </button>
              <button type="button" onClick={onSatisfied} className="neutral">
                <GraphicalIcon icon="neutral-face" />
                Acceptable
              </button>
              <button type="button" onClick={onHappy} className="happy">
                <GraphicalIcon icon="happy-face" />
                It was good!
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
