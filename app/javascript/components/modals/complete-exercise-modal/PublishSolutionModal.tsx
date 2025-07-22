import React from 'react'
import { Modal, ModalProps } from '../Modal'
import { GraphicalIcon } from '../../common'
import { PublishSolutionForm } from './PublishSolutionForm'
import { ExerciseCompletion } from '../CompleteExerciseModal'
import { Iteration } from '../../types'
import { generateAriaFieldIds } from '@/utils/generate-aria-field-ids'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const PublishSolutionModal = ({
  open,
  iterations,
  endpoint,
  onSuccess,
  ...props
}: Omit<ModalProps, 'className'> & {
  open: boolean
  iterations: readonly Iteration[]
  endpoint: string
  onSuccess: (data: ExerciseCompletion) => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/complete-exercise-modal')
  const ariaObject = generateAriaFieldIds('publish-code')
  return (
    <Modal
      cover={true}
      open={open}
      aria={ariaObject}
      className="m-publish-exercise"
      closeButton
      {...props}
    >
      <div className="content">
        <GraphicalIcon icon="publish" className="publish-icon" />
        <h2 id={ariaObject.labelledby} className="title">
          {t('publishSolutionModal.publishKnowledge')}
        </h2>
        <p id={ariaObject.describedby}>
          {t('publishSolutionModal.publishHelpOthers')}
        </p>
        <PublishSolutionForm
          endpoint={endpoint}
          iterations={iterations}
          onSuccess={onSuccess}
        />
      </div>
      <GraphicalIcon
        icon="laptop-man-1"
        className="decorative-image"
        category="graphics"
      />
    </Modal>
  )
}
