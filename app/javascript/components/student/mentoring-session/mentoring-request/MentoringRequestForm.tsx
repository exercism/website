import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { MedianWaitTime } from '@/components/common/MedianWaitTime'
import CopyToClipboardButton from '@/components/common/CopyToClipboardButton'
import { FormButton } from '@/components/common/FormButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { useMentoringRequest } from './MentoringRequestFormComponents'
import type {
  MentorSessionTrack as Track,
  MentorSessionExercise as Exercise,
  MentorSessionRequest as Request,
  DiscussionLinks,
} from '@/components/types'
import {
  TrackObjectivesTextArea,
  SolutionCommentTextArea,
} from './MentoringRequestFormComponents'

const DEFAULT_ERROR = new Error('Unable to create mentor request')

export const MentoringRequestForm = ({
  trackObjectives,
  track,
  exercise,
  links,
  onSuccess,
}: {
  trackObjectives: string
  track: Track
  exercise: Exercise
  links: DiscussionLinks
  onSuccess: (mentorRequest: Request) => void
}): JSX.Element => {
  const {
    error,
    handleSubmit,
    solutionCommentRef,
    status,
    trackObjectivesRef,
  } = useMentoringRequest(links, onSuccess)

  return (
    <div className="mentoring-request-section">
      <div className="direct">
        <h3>
          Send this link to a friend for private mentoring.{' '}
          <a href={links.learnMoreAboutPrivateMentoring}>Learn more</a>.
        </h3>
        <CopyToClipboardButton textToCopy={links.privateMentoring} />
      </div>
      <form
        data-turbo="false"
        className="c-mentoring-request-form"
        onSubmit={handleSubmit}
      >
        <div className="heading">
          <div className="info">
            <h2>It&apos;s time to deepen your knowledge.</h2>
            <p>
              Start a mentoring discussion on <strong>{exercise.title}</strong>{' '}
              to discover new and exciting ways to approach it. Expand and
              deepen your knowledge.
            </p>
          </div>
          <GraphicalIcon icon="mentoring" category="graphics" />
        </div>
        <TrackObjectivesTextArea
          defaultValue={trackObjectives}
          track={track}
          ref={trackObjectivesRef}
        />
        <SolutionCommentTextArea ref={solutionCommentRef} />
        <FormButton status={status} className="btn-primary btn-m">
          Submit mentoring request
        </FormButton>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        />
        <p className="flow-explanation">
          Once you submit, your request will be open for a mentor to join and
          start providing feedback.
          <MedianWaitTime seconds={track.medianWaitTime} />
        </p>
      </form>
    </div>
  )
}
