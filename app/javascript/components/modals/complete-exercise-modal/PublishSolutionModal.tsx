import React from 'react'
import { Modal } from '../Modal'
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
}: {
  open: boolean
  iterations: readonly Iteration[]
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
