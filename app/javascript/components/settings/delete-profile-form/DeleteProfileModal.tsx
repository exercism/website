import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { redirectTo } from '@/utils/redirect-to'
import { sendRequest } from '@/utils/send-request'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to delete profile')

export const DeleteProfileModal = ({
  endpoint,
  onClose,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
}): JSX.Element => {
  const { t } = useAppTranslation('components/settings/delete-profile-form')
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'DELETE',
        body: null,
      })

      return fetch
    },
    onSuccess: () => redirectTo(''),
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
    <Modal className="m-generic-confirmation" onClose={handleClose} {...props}>
      <h3>{t('deleteProfileModal.deleteProfile')}</h3>
      <p>{t('deleteProfileModal.areYouSure')}</p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton type="submit" status={status} className="btn-primary btn-s">
          {t('deleteProfileModal.continue')}
        </FormButton>
        <FormButton
          type="button"
          status={status}
          onClick={handleClose}
          className="btn-enhanced btn-s"
        >
          {t('deleteProfileModal.cancel')}
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
