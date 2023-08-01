import React, { useCallback } from 'react'
import { redirectTo } from '@/utils/redirect-to'
import { Modal } from './Modal'
import { Props } from '../editor/Props'
import { IterationsListRequest } from '../student/IterationsList'
import { Submission } from '../editor/types'
import { FeedbackContent } from './realtime-feedback-modal/FeedbackContent'
import { useGetLatestIteration } from './realtime-feedback-modal/useGetLatestIteration'
import { Iteration, Track } from '../types'

export type RealtimeFeedbackModalProps = {
  open: boolean
  onClose: () => void
  onSubmit: () => void
  track: Pick<Track, 'iconUrl' | 'title'>
  automatedFeedbackInfoLink: string
  request: IterationsListRequest
  redirectToExerciseLink: string
  submission: Submission | null
  mentorDiscussionsLink: string
} & Pick<Props, 'exercise' | 'solution'>

export type ResolvedIteration = Iteration & { submissionUuid?: string }

export const RealtimeFeedbackModal = ({
  open,
  onClose,
  solution,
  exercise,
  track,
  request,
  automatedFeedbackInfoLink,
  mentorDiscussionsLink,
  redirectToExerciseLink,
  submission,
}: RealtimeFeedbackModalProps): JSX.Element => {
  const { latestIteration, checkStatus } = useGetLatestIteration({
    request,
    submission,
    solution,
  })

  const redirectToExercise = useCallback(() => {
    redirectTo(redirectToExerciseLink)
  }, [redirectToExerciseLink])

  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick
      ReactModalClassName="w-fill max-w-[700px]"
    >
      <FeedbackContent
        checkStatus={checkStatus}
        open={open}
        continueAnyway={redirectToExercise}
        exercise={exercise}
        solution={solution}
        track={track}
        latestIteration={latestIteration}
        onClose={onClose}
        automatedFeedbackInfoLink={automatedFeedbackInfoLink}
        mentorDiscussionsLink={mentorDiscussionsLink}
      />
    </Modal>
  )
}
