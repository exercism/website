import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { redirectTo } from '@/utils/redirect-to'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { MentorSessionRequest } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to cancel request')

type APIResponse = {
  links: {
    home: string
  }
}

export const CancelRequestModal = ({
  open,
  onClose,
  request,
  ...props
}: Omit<ModalProps, 'className'> & {
  request: MentorSessionRequest
}): JSX.Element => {
  const { t } = useAppTranslation(
    'components/student/mentoring-session/mentoring-request'
  )
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<APIResponse>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: request.links.cancel,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: (response) => {
      redirectTo(response.links.home)
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
  }, [status, onClose])

  return (
    <Modal
      open={open}
      onClose={handleClose}
      className="m-generic-confirmation"
      {...props}
    >
      <h3>{t('cancelRequestModal.cancelMentoringRequest')}</h3>
      <p>{t('cancelRequestModal.areYouSure')}</p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton status={status} type="submit" className="btn-primary btn-s">
          {t('cancelRequestModal.cancelMentoringRequestButton')}
        </FormButton>
        <FormButton
          status={status}
          type="button"
          className="btn-enhanced btn-s"
          onClick={handleClose}
        >
          {t('cancelRequestModal.close')}
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
