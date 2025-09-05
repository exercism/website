import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { SolutionForStudent } from '@/components/types'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { Modal, ModalProps } from './Modal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to enable comments')

export const EnableSolutionCommentsModal = ({
  endpoint,
  onSuccess,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  onSuccess: () => void
}): JSX.Element => {
  const { t } = useAppTranslation()
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<SolutionForStudent>({
    mutationFn: async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    onSuccess: () => {
      props.onClose()
      onSuccess()
    },
  })

  return (
    <Modal {...props} className="m-generic-confirmation">
      <h3>{t('enableSolutionCommentsModal.enableComments')}</h3>
      <p>{t('enableSolutionCommentsModal.enablingCommentsAllows')}</p>

      <div className="buttons">
        <FormButton
          type="button"
          onClick={() => mutation()}
          status={status}
          className="btn-primary btn-m"
        >
          {t('enableSolutionCommentsModal.enableCommentsButton')}
        </FormButton>
        <FormButton
          type="button"
          onClick={props.onClose}
          status={status}
          className="btn-default btn-m"
        >
          {t('enableSolutionCommentsModal.cancel')}
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage
          error={error}
          defaultError={
            DEFAULT_ERROR ||
            new Error(t('enableSolutionCommentsModal.unableToEnableComments'))
          }
        />
      </ErrorBoundary>
    </Modal>
  )
}
