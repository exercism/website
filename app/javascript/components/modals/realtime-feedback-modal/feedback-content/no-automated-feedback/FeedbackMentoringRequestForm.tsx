import React, { useRef, useCallback } from 'react'
import { useMutation } from 'react-query'
import { sendRequest, typecheck } from '@/utils'
import { MedianWaitTime } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import type {
  MentorSessionTrack as Track,
  MentorSessionRequest as Request,
} from '@/components/types'
import { ContinueButton } from '../../components/FeedbackContentButtons'
import { RealtimeFeedbackModalProps } from '../..'

const DEFAULT_ERROR = new Error('Unable to create mentor request')

export const FeedbackMentoringRequestForm = ({
  trackObjectives,
  track,
  links,
  onContinue,
  onSuccess,
}: {
  trackObjectives: string
  track: Pick<Track, 'title' | 'medianWaitTime'>
  onContinue: () => void
  onSuccess: () => void
} & Pick<RealtimeFeedbackModalProps, 'links'>): JSX.Element => {
  const [mutation, { status, error }] = useMutation<Request>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: links.createMentorRequest,
        method: 'POST',
        body: JSON.stringify({
          comment: solutionCommentRef.current?.value,
          track_objectives: trackObjectivesRef.current?.value,
        }),
      })

      return fetch.then((json) => typecheck<Request>(json, 'mentorRequest'))
    },
    {
      onSuccess,
    }
  )

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const trackObjectivesRef = useRef<HTMLTextAreaElement>(null)
  const solutionCommentRef = useRef<HTMLTextAreaElement>(null)

  return (
    <form
      data-turbo="false"
      className="c-mentoring-request-form realtime-feedback-modal-form"
      onSubmit={handleSubmit}
    >
      <h3 className="text-h4 mb-8">Request code review</h3>
      <div className="question">
        <label htmlFor="request-mentoring-form-track-objectives">
          What are you hoping to learn from this track?
        </label>
        <p id="request-mentoring-form-track-description">
          Tell our mentors a little about your programming background and what
          you&apos;re aiming to learn from {track.title}.
        </p>
        <textarea
          ref={trackObjectivesRef}
          id="request-mentoring-form-track-objectives"
          required
          aria-describedby="request-mentoring-form-track-description"
          defaultValue={trackObjectives}
        />
      </div>
      <div className="question">
        <label htmlFor="request-mentoring-form-solution-comment">
          How can a mentor help you with this solution?
        </label>
        <p id="request-mentoring-form-solution-description">
          Give your mentor a starting point for the conversation. This will be
          your first comment during the session. Markdown is permitted.
        </p>
        <textarea
          ref={solutionCommentRef}
          id="request-mentoring-form-solution-comment"
          required
          aria-describedby="request-mentoring-form-solution-description"
        />
      </div>
      <div className="flex gap-8">
        <ContinueButton
          type="button"
          text="Cancel"
          className="!w-auto btn-secondary"
          onClick={onContinue}
        />
        <FormButton
          status={status}
          className="!w-auto btn-primary btn-s flex-grow"
        >
          Submit for code review
        </FormButton>
      </div>
      <FetchingBoundary
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      ></FetchingBoundary>
      <p className="flow-explanation">
        Once you submit, your request will be open for a mentor to join and
        start providing feedback.
        <MedianWaitTime seconds={track.medianWaitTime} />
      </p>
    </form>
  )
}
