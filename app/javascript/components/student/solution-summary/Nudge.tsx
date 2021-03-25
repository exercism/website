import React from 'react'
import { GraphicalIcon, Icon } from '../../common'
import { Iteration, IterationStatus } from '../../types'
import { CompleteExerciseButton } from '../CompleteExerciseButton'
import { MentoringComboButton } from './MentoringComboButton'
import { MentorDiscussion } from '../../types'

type Links = {
  mentoringInfo: string
  completeExercise: string
  requestMentoring: string
  shareMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

export const Nudge = ({
  hasMentorDiscussionInProgress,
  hasMentorRequestPending,
  discussions,
  iteration,
  isConceptExercise,
  links,
}: {
  iteration: Iteration
  isConceptExercise: boolean
  hasMentorDiscussionInProgress: boolean
  hasMentorRequestPending: boolean
  discussions: readonly MentorDiscussion[]
  links: Links
}): JSX.Element | null => {
  switch (iteration.status) {
    case IterationStatus.NON_ACTIONABLE_AUTOMATED_FEEDBACK:
    case IterationStatus.NO_AUTOMATED_FEEDBACK: {
      return isConceptExercise ? (
        <CompleteExerciseNudge completeExerciseLink={links.completeExercise} />
      ) : (
        <MentoringNudge
          hasMentorDiscussionInProgress={hasMentorDiscussionInProgress}
          hasMentorRequestPending={hasMentorRequestPending}
          discussions={discussions}
          links={links}
        />
      )
    }
    default:
      return null
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
  hasMentorDiscussionInProgress,
  hasMentorRequestPending,
  discussions,
  links,
}: {
  hasMentorDiscussionInProgress: boolean
  hasMentorRequestPending: boolean
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
            hasMentorDiscussionInProgress={hasMentorDiscussionInProgress}
            hasMentorRequestPending={hasMentorRequestPending}
            discussions={discussions}
            links={links}
            className="btn-small-cta"
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
