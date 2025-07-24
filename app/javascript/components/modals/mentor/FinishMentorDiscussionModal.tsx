import React from 'react'
import { MutationStatus } from '@tanstack/react-query'
import { Loading } from '@/components/common'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, useErrorHandler } from '@/components/ErrorBoundary'
import { Modal } from '../Modal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to end discussion')

const ErrorHandler = ({ error }: { error: unknown }) => {
  useErrorHandler(error, { defaultError: DEFAULT_ERROR })

  return null
}

export const FinishMentorDiscussionModal = ({
  open,
  onFinish,
  onCancel,
  status,
  error,
  ...props
}: {
  endpoint: string
  open: boolean
  status: MutationStatus
  error: unknown
  onFinish: () => void
  onCancel: () => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/modals/mentor')

  return (
    <Modal
      open={open}
      onClose={onCancel}
      className="m-generic-confirmation"
      {...props}
    >
      <h3>{t('finishMentorDiscussionModal.areYouSure')}</h3>
      <p>{t('finishMentorDiscussionModal.explanation')}</p>
      <div className="buttons">
        <FormButton
          type="button"
          className="btn-small-discourage"
          onClick={onCancel}
          status={status}
        >
          {t('finishMentorDiscussionModal.cancel')}
        </FormButton>
        <FormButton
          type="button"
          className="btn-primary btn-s"
          onClick={onFinish}
          status={status}
        >
          {t('finishMentorDiscussionModal.endDiscussion')}
        </FormButton>
      </div>

      {status === 'pending' ? <Loading /> : null}
      {status === 'error' ? (
        <ErrorBoundary>
          <ErrorHandler error={error} />
        </ErrorBoundary>
      ) : null}
    </Modal>
  )
}
