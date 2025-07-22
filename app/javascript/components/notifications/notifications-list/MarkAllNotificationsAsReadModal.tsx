import React, { useCallback } from 'react'
import { MutationStatus } from '@tanstack/react-query'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to mark all notifications as read')

export const MarkAllNotificationsAsReadModal = ({
  mutation,
  onClose,
  onSubmit,
  ...props
}: Omit<ModalProps, 'className'> & {
  mutation: {
    status: MutationStatus
    error: unknown
  }
  onSubmit: () => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/notifications/notifications-list')
  const handleClose = useCallback(() => {
    if (mutation.status === 'pending') {
      return
    }

    onClose()
  }, [mutation.status, onClose])

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      onSubmit()
      handleClose()
    },
    [onSubmit, handleClose]
  )

  return (
    <Modal className="m-generic-confirmation" onClose={handleClose} {...props}>
      <h3>{t('markAllNotificationsAsReadModal.markAllAsRead')}</h3>
      <p>{t('markAllNotificationsAsReadModal.areYouSure')}</p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton
          type="submit"
          status={mutation.status}
          className="btn-primary btn-s"
        >
          {t('markAllNotificationsAsReadModal.continue')}
        </FormButton>
        <FormButton
          type="button"
          status={mutation.status}
          onClick={handleClose}
          className="btn-enhanced btn-s"
        >
          {t('markAllNotificationsAsReadModal.cancel')}
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[mutation.status]}>
        <ErrorMessage error={mutation.error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
