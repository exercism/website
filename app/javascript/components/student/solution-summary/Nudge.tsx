import React from 'react'
import { Avatar, GraphicalIcon, Icon } from '../../common'
import { Iteration, IterationStatus } from '../../types'
import { CompleteExerciseButton } from '../CompleteExerciseButton'
import { MentoringComboButton } from './MentoringComboButton'
import { MentorDiscussion, SolutionMentoringStatus } from '../../types'
import { Track } from '../SolutionSummary'
import pluralize from 'pluralize'

type Links = {
  mentoringInfo: string
  completeExercise: string
  requestMentoring: string
  shareMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

export const Nudge = ({
  mentoringStatus,
  discussions,
  iteration,
  isConceptExercise,
  links,
  track,
}: {
  iteration: Iteration
  isConceptExercise: boolean
  mentoringStatus: SolutionMentoringStatus
  discussions: readonly MentorDiscussion[]
  links: Links
  track: Track
}): JSX.Element | null => {
  switch (mentoringStatus) {
    case 'requested':
      return <MentoringRequestedNudge track={track} links={links} />
    case 'in_progress':
      return <InProgressMentoringNudge discussion={discussions[0]} />
    default:
      switch (iteration.status) {
        case IterationStatus.NON_ACTIONABLE_AUTOMATED_FEEDBACK:
        case IterationStatus.NO_AUTOMATED_FEEDBACK: {
          return isConceptExercise ? (
            <CompleteExerciseNudge
              completeExerciseLink={links.completeExercise}
            />
          ) : (
            <MentoringNudge
              mentoringStatus={mentoringStatus}
              discussions={discussions}
              links={links}
            />
          )
        }
        case IterationStatus.TESTS_FAILED:
          return <TestsFailedNudge track={track} links={links} />
        default:
          return null
      }
  }
}

const CompleteExerciseNudge = ({
  completeExerciseLink,
}: {
  completeExerciseLink: string
}) => {
  return (
    <section className="completion-nudge">
      <GraphicalIcon icon="complete" category="graphics" />
      <div className="info">
        <h3>Hey, looks like you’re done here!</h3>
        <p>
          Complete the exercise to unlock new concepts and exercises.{' '}
          <strong>
            Remember, you can get mentored even after you’ve completed the
            exercise.
          </strong>
        </p>
      </div>
      <CompleteExerciseButton endpoint={completeExerciseLink} />
    </section>
  )
}

const MentoringNudge = ({
  mentoringStatus,
  discussions,
  links,
}: {
  mentoringStatus: SolutionMentoringStatus
  discussions: readonly MentorDiscussion[]
  links: {
    mentoringInfo: string
    requestMentoring: string
    shareMentoring: string
    pendingMentorRequest: string
    inProgressDiscussion?: string
  }
}) => {
  return (
    <section className="mentoring-nudge">
      <GraphicalIcon icon="mentoring-screen" category="graphics" />
      <div className="info">
        <h3>Improve your solution with mentoring</h3>
        <p>
          On average, students that get mentoring iterate a further 3.5 times on
          their solution. It’s a great way to discover what you don’t know about
          your language.
        </p>
        <div className="options">
          <MentoringComboButton
            mentoringStatus={mentoringStatus}
            discussions={discussions}
            links={links}
          />{' '}
          <a
            href={links.mentoringInfo}
            className="more-info"
            target="_blank"
            rel="noreferrer"
          >
            What is Mentoring?
            <Icon icon="external-link" alt="Opens in a new tab" />
          </a>
        </div>
      </div>
    </section>
  )
}

const TestsFailedNudge = ({
  track,
  links,
}: {
  track: Track
  links: {
    mentoringInfo: string
    requestMentoring: string
  }
}) => {
  return (
    <section className="mentoring-nudge">
      <GraphicalIcon icon="mentoring-screen" category="graphics" />
      <div className="info">
        <h3>Struggling with this exercise?</h3>
        <p>Get some help from our awesome {track.title} mentors.</p>
        <div className="options">
          <a href={links.requestMentoring}>Request mentoring</a>
          <a
            href={links.mentoringInfo}
            className="more-info"
            target="_blank"
            rel="noreferrer"
          >
            What is Mentoring?
            <Icon icon="external-link" alt="Opens in a new tab" />
          </a>
        </div>
      </div>
    </section>
  )
}

const MentoringRequestedNudge = ({
  track,
  links,
}: {
  track: Track
  links: {
    mentoringInfo: string
    pendingMentorRequest: string
  }
}) => {
  return (
    <section className="mentoring-nudge">
      <div className="info">
        <h3>You&apos;ve requested mentoring</h3>
        <p>Waiting on a mentor... (Median wait time {track.medianWaitTime})</p>
        <div className="options">
          <a href={links.pendingMentorRequest}>Open request</a>
        </div>
      </div>
    </section>
  )
}

const InProgressMentoringNudge = ({
  discussion,
}: {
  discussion: MentorDiscussion
}) => {
  return (
    <section className="mentoring-nudge">
      <div className="info">
        <Avatar
          src={discussion.mentor.avatarUrl}
          handle={discussion.mentor.handle}
        />
        <Avatar
          src={discussion.student.avatarUrl}
          handle={discussion.student.handle}
        />
        <h3>You&apos;re being mentored by {discussion.mentor.handle}</h3>
        <span>
          {discussion.postsCount} {pluralize('comments', discussion.postsCount)}
        </span>
        <a href={discussion.links.self}>Open discussion</a>
      </div>
    </section>
  )
}
