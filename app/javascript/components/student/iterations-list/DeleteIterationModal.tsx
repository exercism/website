// i18n-key-prefix: deleteIterationModal
// i18n-namespace: components/student/iterations-list
import React, { useCallback } from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { Modal, ModalProps } from '@/components/modals/Modal'
import { Iteration } from '@/components/types'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

const DEFAULT_ERROR = new Error('Unable to delete iteration')

export const DeleteIterationModal = ({
  iteration,
  onClose,
  onSuccess,
  ...props
}: Omit<ModalProps, 'className'> & {
  iteration: Iteration
  onSuccess: (iteration: Iteration) => void
}): JSX.Element => {
  const { t } = useAppTranslation('components/student/iterations-list')
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: iteration.links.delete,
        method: 'DELETE',
        body: null,
      })

      return fetch.then((json) => typecheck<Iteration>(json, 'iteration'))
    },
    onSuccess,
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
      className="m-generic-confirmation"
      shouldCloseOnEsc={false}
      onClose={handleClose}
      {...props}
    >
      <h3>
        {t('deleteIterationModal.areYouSure', { iterationIdx: iteration.idx })}
      </h3>
      <p>{t('deleteIterationModal.deletedIterationsRemoved')}</p>
      <form data-turbo="false" onSubmit={handleSubmit} className="buttons">
        <FormButton type="submit" status={status} className="btn-warning btn-s">
          {t('deleteIterationModal.deleteIteration')}
        </FormButton>
        <FormButton
          type="button"
          status={status}
          onClick={handleClose}
          className="btn-enhanced btn-s"
        >
          {t('deleteIterationModal.cancel')}
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
