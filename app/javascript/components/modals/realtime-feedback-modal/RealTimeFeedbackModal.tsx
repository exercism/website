import React, { useCallback, useState } from 'react'
import { redirectTo } from '@/utils/redirect-to'
import { Modal } from '../Modal'
import { FeedbackContent } from './FeedbackContent'
import { useGetLatestIteration } from './hooks/useGetLatestIteration'
import type { Props } from '@/components/editor/Props'
import type { IterationsListRequest } from '@/components/student/IterationsList'
import type { Submission } from '@/components/editor/types'
import type { Iteration } from '@/components/types'
import { DeepDiveVideoContent } from './feedback-content/DeepDiveVideoContent'

export type RealtimeFeedbackModalProps = {
  open: boolean
  onClose: () => void
  onSubmit: () => void
  request: IterationsListRequest
  showDeepDiveVideo: boolean
  submission: Submission | null
  links: Props['links'] & { redirectToExerciseLink: string }
} & Pick<
  Props,
  | 'exercise'
  | 'solution'
  | 'trackObjectives'
  | 'track'
  | 'mentoringStatus'
  | 'discussion'
  | 'hasAvailableMentoringSlot'
>

export type ResolvedIteration = Iteration & { submissionUuid?: string }

export const RealtimeFeedbackModal = ({
  open,
  onClose,
  solution,
  track,
  request,
  submission,
  links,
  trackObjectives,
  mentoringStatus,
  exercise,
  showDeepDiveVideo,
  hasAvailableMentoringSlot,
}: RealtimeFeedbackModalProps): JSX.Element => {
  const { latestIteration, checkStatus } = useGetLatestIteration({
    request,
    submission,
    solution,
    feedbackModalOpen: open,
  })

  const [showVideoStep, setShowVideoStep] = useState(false)

  const redirectToExercise = useCallback(() => {
    redirectTo(links.redirectToExerciseLink)
  }, [links.redirectToExerciseLink])

  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick={false}
      ReactModalClassName="w-fill max-w-[700px]"
    >
      {showVideoStep ? (
        <DeepDiveVideoContent
          exercise={exercise}
          onContinue={redirectToExercise}
          links={links}
        />
      ) : (
        <FeedbackContent
          checkStatus={checkStatus}
          open={open}
          onContinue={() =>
            showDeepDiveVideo ? setShowVideoStep(true) : redirectToExercise()
          }
          track={track}
          latestIteration={latestIteration}
          onClose={onClose}
          links={links}
          trackObjectives={trackObjectives}
          mentoringStatus={mentoringStatus}
          hasAvailableMentoringSlot={hasAvailableMentoringSlot}
        />
      )}
    </Modal>
  )
}
