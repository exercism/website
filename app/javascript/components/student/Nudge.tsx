import React, { useState, useEffect, useCallback, useRef } from 'react'
import { Avatar, GraphicalIcon, HandleWithFlair, Icon } from '../common'
import {
  IterationStatus,
  SolutionForStudent,
  ExerciseType,
  Iteration,
} from '../types'
import { default as CompleteExerciseButton } from './CompleteExerciseButton'
import { MentoringComboButton } from './MentoringComboButton'
import {
  MentorDiscussion,
  SolutionStatus,
  SolutionMentoringStatus,
} from '../types'
import { LatestIterationStatusChannel } from '../../channels/latestIterationStatusChannel'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import pluralize from 'pluralize'
import { useQueryCache } from 'react-query'

export type Track = {
  title: string
  medianWaitTime?: number
}

export type Links = {
  mentoringInfo: string
  completeExercise: string
  requestMentoring: string
  shareMentoring: string
  pendingMentorRequest: string
  inProgressDiscussion?: string
}

type Props = {
  solution: SolutionForStudent
  exerciseType: ExerciseType
  request: Request
  discussions: readonly MentorDiscussion[]
  links: Links
  iterations: readonly Iteration[]
  track: Track
}

type NudgeType =
  | 'mentoringRequested'
  | 'inProgress'
  | 'completeExercise'
  | 'mentoring'
  | 'testsFailed'

const REFETCH_INTERVAL = 2000

export default function Nudge({
  solution,
  exerciseType,
  request,
  discussions,
  links,
  iterations,
  track,
}: Props): JSX.Element | null {
  const queryCache = useQueryCache()
  const CACHE_KEY = `nudge-${solution.uuid}`
  const [queryEnabled, setQueryEnabled] = useState(true)
  const { resolvedData } = usePaginatedRequestQuery<{
    status: IterationStatus
  }>(CACHE_KEY, {
    ...request,
    options: {
      ...request.options,
      refetchInterval: queryEnabled ? REFETCH_INTERVAL : false,
    },
  })

  const iterationStatus = resolvedData?.status

  useEffect(() => {
    switch (iterationStatus) {
      case IterationStatus.DELETED:
      case IterationStatus.TESTING:
      case IterationStatus.ANALYZING:
        setQueryEnabled(true)
        break
      default:
        setQueryEnabled(false)
        break
    }
  }, [iterationStatus])

  const getNudgeType = useCallback(() => {
    switch (solution.mentoringStatus) {
      case 'requested':
        return 'mentoringRequested'
      case 'in_progress':
        return 'inProgress'
      default: {
        switch (iterationStatus) {
          case IterationStatus.NON_ACTIONABLE_AUTOMATED_FEEDBACK:
          case IterationStatus.CELEBRATORY_AUTOMATED_FEEDBACK:
          case IterationStatus.NO_AUTOMATED_FEEDBACK: {
            switch (exerciseType) {
              case 'concept':
              case 'tutorial':
                return 'completeExercise'
              case 'practice':
                return 'mentoring'
            }
            break
          }
          case IterationStatus.TESTS_FAILED:
            return 'testsFailed'
          default:
            return null
        }
      }
    }
  }, [exerciseType, iterationStatus, solution.mentoringStatus])
  const [nudgeType, setNudgeType] = useState<NudgeType | null>(getNudgeType())
  const initNudgeTypeRef = useRef<NudgeType | null>(nudgeType)
  const [shouldAnimate, setShouldAnimate] = useState(false)

  useEffect(() => {
    const channel = new LatestIterationStatusChannel(
      solution.uuid,
      (response) => {
        queryCache.setQueryData(CACHE_KEY, response)
      }
    )

    return () => {
      channel.disconnect()
    }
  }, [CACHE_KEY, solution, queryCache])

  useEffect(() => {
    setNudgeType(getNudgeType())
  }, [getNudgeType])

  useEffect(() => {
    if (initNudgeTypeRef.current === nudgeType) {
      return
    }

    setShouldAnimate(true)
  }, [nudgeType])

  const className = shouldAnimate ? 'animate' : ''

  switch (nudgeType) {
    case 'mentoringRequested':
      return <MentoringRequestedNudge links={links} className={className} />
    case 'inProgress':
      return (
        <InProgressMentoringNudge
          discussion={discussions[0]}
          className={className}
        />
      )
    case 'completeExercise':
      return (
        <CompleteExerciseNudge
          status={solution.status}
          iterations={iterations}
          completeExerciseLink={links.completeExercise}
          className={className}
        />
      )
    case 'mentoring':
      return (
        <MentoringNudge
          mentoringStatus={solution.mentoringStatus}
          discussions={discussions}
          links={links}
          className={className}
        />
      )
    case 'testsFailed':
      return (
        <TestsFailedNudge track={track} links={links} className={className} />
      )
    default:
      return null
  }
}

const CompleteExerciseNudge = ({
  status,
  iterations,
  completeExerciseLink,
  className = '',
}: {
  status: SolutionStatus
  iterations: readonly Iteration[]
  completeExerciseLink: string
  className?: string
}) => {
  if (status == 'published' || status == 'completed') {
    return null
  }

  const classNames = ['completion-nudge', className].filter(
    (className) => className.length > 0
  )

  return (
    <section className={classNames.join(' ')}>
      <GraphicalIcon icon="complete" category="graphics" />
      <div className="info">
        <h3>Nice, it looks like you&apos;re done here!</h3>
        <p>
          Complete the exercise to unlock new concepts and exercises.{' '}
          <strong>
            Remember, you can request code review even after you’ve completed
            the exercise.
          </strong>
        </p>
      </div>
      <CompleteExerciseButton
        iterations={iterations}
        endpoint={completeExerciseLink}
      />
    </section>
  )
}

const MentoringNudge = ({
  mentoringStatus,
  discussions,
  links,
  className = '',
}: {
  mentoringStatus: SolutionMentoringStatus
  discussions: readonly MentorDiscussion[]
  className?: string
  links: {
    mentoringInfo: string
    requestMentoring: string
    shareMentoring: string
    pendingMentorRequest: string
    inProgressDiscussion?: string
  }
}) => {
  const classNames = ['mentoring-prompt-nudge', className].filter(
    (className) => className.length > 0
  )

  if (mentoringStatus === 'finished') {
    return null
  }

  return (
    <section className={classNames.join(' ')}>
      <GraphicalIcon icon="mentoring-screen" category="graphics" />
      <div className="info">
        <h3>Improve your solution with code review</h3>
        <p>
          Having your code reviewed by a mentor is an incredible way to identify
          your knowledge gaps and accelerate your learning. It&apos;s totally
          free.
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
            What is Code Review?
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
  className = '',
}: {
  track: Track
  links: {
    mentoringInfo: string
    requestMentoring: string
  }
  className?: string
}) => {
  const classNames = ['mentoring-prompt-nudge', className].filter(
    (className) => className.length > 0
  )

  return (
    <section className={classNames.join(' ')}>
      <GraphicalIcon icon="mentoring-screen" category="graphics" />
      <div className="info">
        <h3>Struggling with this exercise?</h3>
        <p>Get some help from our awesome {track.title} mentors.</p>
        <div className="options">
          <a href={links.requestMentoring} className="btn-primary btn-s">
            Submit for Code Review
          </a>
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
  links,
  className = '',
}: {
  links: {
    mentoringInfo: string
    pendingMentorRequest: string
  }
  className?: string
}) => {
  const classNames = ['mentoring-request-nudge', className].filter(
    (className) => className.length > 0
  )

  return (
    <section className={classNames.join(' ')}>
      <div className="info">
        <h3>You&apos;ve requested mentoring</h3>
        <p>Waiting on a mentor...</p>
      </div>
      <a href={links.pendingMentorRequest} className="btn-primary btn-s">
        Open request
      </a>
    </section>
  )
}

const InProgressMentoringNudge = ({
  discussion,
  className = '',
}: {
  discussion: MentorDiscussion
  className?: string
}) => {
  const classNames = [
    'mentoring-discussion-nudge',
    'c-mentor-discussion-widget',
    className,
  ].filter((className) => className.length > 0)

  return (
    <section className={classNames.join(' ')}>
      <Avatar
        src={discussion.student.avatarUrl}
        handle={discussion.student.handle}
        className="student-avatar"
      />
      <Avatar
        src={discussion.mentor.avatarUrl}
        handle={discussion.mentor.handle}
        className="mentor-avatar"
      />

      <div className="info">
        <h3 className="flex">
          You&apos;re being mentored by&nbsp;
          <strong>
            {
              <HandleWithFlair
                handle={discussion.mentor.handle}
                flair={discussion.mentor.flair}
                size="large"
              />
            }
          </strong>
        </h3>
        <div className="details">
          {discussion.status === 'awaiting_student' ? (
            <div className="--turn">Your turn to respond</div>
          ) : null}
          <div className="--comments">
            <GraphicalIcon icon="comment" />
            {discussion.postsCount}{' '}
            {pluralize('comments', discussion.postsCount)}
          </div>
        </div>
      </div>
      <a href={discussion.links.self} className="btn-primary btn-s">
        Open discussion
      </a>
    </section>
  )
}
