import React, { useCallback } from 'react'
import { redirectTo } from '@/utils'
import { Modal } from '../Modal'
import { FeedbackContent } from './FeedbackContent'
import { useGetLatestIteration } from './hooks/useGetLatestIteration'
import type { Props } from '@/components/editor/Props'
import type { IterationsListRequest } from '@/components/student/IterationsList'
import type { Submission } from '@/components/editor/types'
import type { Iteration } from '@/components/types'

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
  discussion,
}: RealtimeFeedbackModalProps): JSX.Element => {
  const { latestIteration, checkStatus } = useGetLatestIteration({
    request,
    submission,
    solution,
  })

  const redirectToExercise = useCallback(() => {
    redirectTo(links.redirectToExerciseLink)
  }, [links.redirectToExerciseLink])

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
        onContinue={redirectToExercise}
        track={track}
        latestIteration={latestIteration}
        onClose={onClose}
        links={links}
        discussion={discussion}
        trackObjectives={trackObjectives}
        mentoringStatus={mentoringStatus}
      />
    </Modal>
  )
}
