import React, { useCallback, useState } from 'react'
import { redirectTo } from '@/utils'
import { Modal } from '../Modal'
import { FeedbackContent } from './FeedbackContent'
import { useGetLatestIteration } from './hooks/useGetLatestIteration'
import type { Props } from '@/components/editor/Props'
import type { IterationsListRequest } from '@/components/student/IterationsList'
import type { Submission } from '@/components/editor/types'
import type { Iteration } from '@/components/types'
import { DeepDiveVideo } from '@/components/track/dig-deeper-components/DeepDiveVideo'
import { DeepDiveVideoContent } from './feedback-content/DeepDiveVideoContent'
import { useLogger } from '@/hooks'

export type RealtimeFeedbackModalProps = {
  open: boolean
  onClose: () => void
  onSubmit: () => void
  request: IterationsListRequest
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
}: RealtimeFeedbackModalProps): JSX.Element => {
  const { latestIteration, checkStatus } = useGetLatestIteration({
    request,
    submission,
    solution,
    feedbackModalOpen: open,
  })

  const redirectToExercise = useCallback(() => {
    redirectTo(links.redirectToExerciseLink)
  }, [links.redirectToExerciseLink])

  // const shouldShowDeepDiveVideo = videoExists && userHasNeverSeenItVideo && userHasNeverSeenVideoAdStep

  const [showDeepDiveVideo, setShowDeepDiveVideo] = useState(false)

  useLogger('exercise', exercise)

  return (
    <Modal
      open={open}
      closeButton={false}
      onClose={onClose}
      shouldCloseOnEsc={false}
      shouldCloseOnOverlayClick={false}
      ReactModalClassName="w-fill max-w-[700px]"
    >
      {showDeepDiveVideo ? (
        <DeepDiveVideoContent
          exercise={exercise}
          onContinue={redirectToExercise}
        />
      ) : (
        <FeedbackContent
          checkStatus={checkStatus}
          open={open}
          onContinue={() => setShowDeepDiveVideo(true)}
          track={track}
          latestIteration={latestIteration}
          onClose={onClose}
          links={links}
          trackObjectives={trackObjectives}
          mentoringStatus={mentoringStatus}
        />
      )}
    </Modal>
  )
}
