import React from 'react'
import { Modal } from './Modal'
import { GraphicalIcon } from '../common'
import { PublishExerciseForm } from './publish-exercise-modal/PublishExerciseForm'
import { ExerciseCompletion } from './CompleteExerciseModal'

export const PublishExerciseModal = ({
  open,
  endpoint,
  onSuccess,
  ...props
}: {
  open: boolean
  endpoint: string
  onSuccess: (data: ExerciseCompletion) => void
}): JSX.Element => {
  return (
    <Modal
      open={open}
      className="m-publish-exercise"
      onClose={() => {}}
      {...props}
    >
      <div className="content">
        <GraphicalIcon icon="publish" className="publish-icon" />
        <div className="title">Publish your code and share your knowledge</div>
        <p>
          By publishing your code, you'll help others learn from your work. You
          can choose which iterations you publish, add more iterations once its
          publish, and unpublish it at any time.
        </p>
        <PublishExerciseForm endpoint={endpoint} onSuccess={onSuccess} />
      </div>
      <GraphicalIcon
        icon="laptop-man-1"
        className="decorative-image"
        category="graphics"
      />
    </Modal>
  )
}
