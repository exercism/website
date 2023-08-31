import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { SolutionForStudent } from '@/components/types'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { Modal, ModalProps } from './Modal'

const DEFAULT_ERROR = new Error('Unable to enable comments')

export const EnableSolutionCommentsModal = ({
  endpoint,
  onSuccess,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  onSuccess: () => void
}): JSX.Element => {
  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<SolutionForStudent>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: endpoint,
        method: 'PATCH',
        body: null,
      })

      return fetch
    },
    {
      onSuccess: () => {
        props.onClose()
        onSuccess()
      },
    }
  )

  return (
    <Modal {...props} className="m-generic-confirmation">
      <h3>Enable comments?</h3>
      <p>
        Enabling comments allows people to publically post questions and
        thoughts on your solution. You can disable this at any time.
      </p>

      <div className="buttons">
        <FormButton
          type="button"
          onClick={() => mutation()}
          status={status}
          className="btn-primary btn-m"
        >
          Enable comments
        </FormButton>
        <FormButton
          type="button"
          onClick={props.onClose}
          status={status}
          className="btn-default btn-m"
        >
          Cancel
        </FormButton>
      </div>
      <ErrorBoundary>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </Modal>
  )
}
