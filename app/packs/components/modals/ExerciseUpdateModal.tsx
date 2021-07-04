import React from 'react'
import { FetchingBoundary } from '../FetchingBoundary'
import { Modal, ModalProps } from './Modal'
import { Icon } from '../common'
import { useRequestQuery } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import { ExerciseUpdateForm } from './exercise-update-modal/ExerciseUpdateForm'
import { Exercise } from '../types'

type ExerciseDiffFile = {
  filename: string
  diff: string
}
export type ExerciseDiff = {
  files: ExerciseDiffFile[]
  exercise: Exercise
  links: {
    update: string
  }
}

const DEFAULT_ERROR = new Error('Unable to load exercise diff')

export const ExerciseUpdateModal = ({
  endpoint,
  ...props
}: Omit<ModalProps, 'className'> & { endpoint: string }): JSX.Element => {
  const isMountedRef = useIsMounted()

  const { data, status, error } = useRequestQuery<{ diff: ExerciseDiff }>(
    ['exercise-update', endpoint],
    { endpoint: endpoint, options: {} },
    isMountedRef
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
