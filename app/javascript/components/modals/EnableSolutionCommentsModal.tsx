import React from 'react'
import { Modal, ModalProps } from './Modal'
import { useMutation } from 'react-query'
import { sendRequest } from '../../utils/send-request'
import { SolutionForStudent } from '../types'
import { FormButton } from '../common'
import { ErrorBoundary, ErrorMessage } from '../ErrorBoundary'

const DEFAULT_ERROR = new Error('Unable to enable comments')

export const EnableSolutionCommentsModal = ({
  endpoint,
  onSuccess,
  ...props
}: Omit<ModalProps, 'className'> & {
  endpoint: string
  onSuccess: () => void
}): JSX.Element => {
  const [mutation, { status, error }] = useMutation<SolutionForStudent>(
    () => {
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
    <Modal {...props} className="m-enable-solution-comments">
      <h3>Do you want to enable comments?</h3>

      <div className="btns">
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
