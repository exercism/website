// i18n-key-prefix: exerciseUpdateModal
// i18n-namespace: components/modals/ExerciseUpdateModal.tsx
import React from 'react'
import { FetchingBoundary } from '../FetchingBoundary'
import { Modal, ModalProps } from './Modal'
import { Icon, GraphicalIcon } from '../common'
import { useRequestQuery } from '../../hooks/request-query'
import { ExerciseUpdateForm } from './exercise-update-modal/ExerciseUpdateForm'
import { Exercise } from '../types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

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
  const { t } = useAppTranslation('components/modals/ExerciseUpdateModal.tsx')
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
          data.diff.files.length > 0 ? (
            <ExerciseUpdateForm diff={data.diff} onCancel={props.onClose} />
          ) : (
            <AutoUpdatedNotice onClose={props.onClose} />
          )
        ) : null}
      </FetchingBoundary>
    </Modal>
  )
}

const AutoUpdatedNotice = ({ onClose }: { onClose: () => void }) => {
  const { t } = useAppTranslation('components/modals/ExerciseUpdateModal.tsx')
  return (
    <div className="auto-updated-notice flex flex-col items-center text-center">
      <GraphicalIcon
        icon="completed-check-circle"
        height={64}
        width={64}
        className="mb-20"
      />
      <h2 className="text-h3 mb-8">
        {t('exerciseUpdateModal.autoUpdatedTitle')}
      </h2>
      <p className="text-p-large mb-24">
        {t('exerciseUpdateModal.autoUpdatedBody')}
      </p>
      <button
        type="button"
        className="btn-primary btn-m"
        onClick={() => {
          onClose()
          window.location.reload()
        }}
      >
        {t('exerciseUpdateModal.continue')}
      </button>
    </div>
  )
}

const LoadingComponent = () => {
  const { t } = useAppTranslation('components/modals/ExerciseUpdateModal.tsx')
  return (
    <Icon icon="spinner" alt={t('exerciseUpdateModal.loadingExerciseDiff')} />
  )
}
