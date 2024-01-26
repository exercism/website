import React from 'react'
import { MedianWaitTime } from '@/components/common/MedianWaitTime'
import { FormButton } from '@/components/common/FormButton'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import type { MentorSessionTrack as Track } from '@/components/types'
import { ContinueButton } from '../../components/FeedbackContentButtons'
import { RealtimeFeedbackModalProps } from '../../RealTimeFeedbackModal'
import { SolutionCommentTextArea } from '@/components/student/mentoring-session/mentoring-request/MentoringRequestFormComponents/SolutionCommentTextArea'
import { TrackObjectivesTextArea } from '@/components/student/mentoring-session/mentoring-request/MentoringRequestFormComponents/TrackObjectivesTextArea'
import { useMentoringRequest } from '@/components/student/mentoring-session/mentoring-request/MentoringRequestFormComponents'

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
  const {
    handleSubmit,
    error,
    status,
    solutionCommentRef,
    trackObjectivesRef,
  } = useMentoringRequest(links, onSuccess)

  return (
    <form
      data-turbo="false"
      className="c-mentoring-request-form realtime-feedback-modal-form"
      onSubmit={handleSubmit}
    >
      <h3 className="text-h4 mb-8">Request code review</h3>
      <TrackObjectivesTextArea
        defaultValue={trackObjectives}
        ref={trackObjectivesRef}
        track={track}
      />
      <SolutionCommentTextArea ref={solutionCommentRef} />
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
      />
      <p className="flow-explanation">
        Once you submit, your request will be open for a mentor to join and
        start providing feedback.
        <MedianWaitTime seconds={track.medianWaitTime} />
      </p>
    </form>
  )
}
