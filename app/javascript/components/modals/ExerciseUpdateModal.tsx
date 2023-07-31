import React from 'react'
import { FetchingBoundary } from '../FetchingBoundary'
import { Modal, ModalProps } from './Modal'
import { Icon } from '../common'
import { useRequestQuery } from '../../hooks/request-query'
import { ExerciseUpdateForm } from './exercise-update-modal/ExerciseUpdateForm'
import { Exercise } from '../types'

type ExerciseDiffFile = {
  relativePath: string
  diff: string
}
export type ExerciseDiff = {
  files: ExerciseDiffFile[]
  exercise: Exercise
  links: {
    update: string
  }
}

const DEFAULT_ERROR = new Error(
  "Sorry - it seems that we can't work out what needs updating for this exercise. We've been alerted and will have a look."
)

export const ExerciseUpdateModal = ({
  endpoint,
  ...props
}: Omit<ModalProps, 'className'> & { endpoint: string }): JSX.Element => {
  const { data, status, error } = useRequestQuery<{ diff: ExerciseDiff }>(
    ['exercise-update', endpoint],
    { endpoint: endpoint, options: {} }
  )
  return (
    <Modal {...props} className="m-update-exercise">
      <FetchingBoundary
        LoadingComponent={LoadingComponent}
        status={status}
        error={error}
        defaultError={DEFAULT_ERROR}
      >
        {data ? (
          <ExerciseUpdateForm diff={data.diff} onCancel={props.onClose} />
        ) : null}
      </FetchingBoundary>
    </Modal>
  )
}

const LoadingComponent = () => (
  <Icon icon="spinner" alt="Loading exercise diff" />
)
