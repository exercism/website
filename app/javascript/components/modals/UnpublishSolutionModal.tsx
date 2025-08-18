import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { redirectTo } from '@/utils/redirect-to'
import { SolutionForStudent } from '@/components/types'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { Modal, ModalProps } from './Modal'
import { useAppTranslation } from '@/i18n/useAppTranslation'

const DEFAULT_ERROR = new Error('Unable to unpublish solution')

export const UnpublishSolutionModal = ({
  endpoint,
  ...props
}: ModalProps & { endpoint: string }): JSX.Element => {
  const { t } = useAppTranslation(
    'components/modals/UnpublishSolutionModal.tsx'
  )
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

      return fetch.then((json) =>
        typecheck<SolutionForStudent>(json, 'solution')
      )
    },
    onSuccess: (solution) => {
      redirectTo(solution.privateUrl)
    },
  })

  return (
    <Modal {...props} className="m-unpublish-solution">
      <h3>{t('unpublishSolutionModal.title')}</h3>
      <p>{t('unpublishSolutionModal.body')}</p>

      <div className="btns">
        <FormButton
          type="button"
          onClick={() => mutation()}
          status={status}
          className="btn-primary btn-m"
        >
          {t('unpublishSolutionModal.unpublishButton')}
        </FormButton>
        <FormButton
          type="button"
          onClick={props.onClose}
          status={status}
          className="btn-default btn-m"
        >
          {t('unpublishSolutionModal.cancelButton')}
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
