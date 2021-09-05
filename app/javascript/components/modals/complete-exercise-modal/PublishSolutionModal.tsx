import React from 'react'
import { Modal, ModalProps } from '../Modal'
import { GraphicalIcon } from '../../common'
import { PublishSolutionForm } from './PublishSolutionForm'
import { ExerciseCompletion } from '../CompleteExerciseModal'
import { Iteration } from '../../types'

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
  return (
    <Modal cover={true} open={open} className="m-publish-exercise" {...props}>
      <div className="content">
        <GraphicalIcon icon="publish" className="publish-icon" />
        <div className="title">Publish your code and share your knowledge</div>
        <p>
          By publishing your code, you'll help others learn from your work. You
          can choose which iterations you publish, add more iterations once its
          publish, and unpublish it at any time.
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
