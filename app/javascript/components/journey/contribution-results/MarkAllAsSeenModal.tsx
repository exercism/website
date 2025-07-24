import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { APIResult } from '../ContributionsList'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to mark all as seen')

export const MarkAllAsSeenModal = ({
  endpoint,
  onClose,
  onSuccess,
  unseenTotal,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  onSuccess: (response: APIResult) => void
  unseenTotal: number
}): JSX.Element => {
  const { t } = useAppTranslation('components/journey/contribution-results')
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<APIResult>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: (result) => {
      onSuccess(result)
      onClose()
    },
  })

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  const handleClose = useCallback(() => {
    if (status === 'pending') {
      return
    }

    onClose()
  }, [onClose, status])

  return (
    <Modal
      theme="dark"
      className="m-generic-confirmation"
      onClose={handleClose}
      {...props}
    >
      <h3>{t('markAllAsSeenModal.markAllAsSeenQuestion')}</h3>
      <p>{t('markAllAsSeenModal.confirmationMessage', { unseenTotal })}</p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton type="submit" status={status} className="btn-primary btn-s">
          {t('markAllAsSeenModal.continue')}
        </FormButton>
        <FormButton
          type="button"
          status={status}
          onClick={handleClose}
          className="btn-enhanced btn-s"
        >
          {t('markAllAsSeenModal.cancel')}
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
