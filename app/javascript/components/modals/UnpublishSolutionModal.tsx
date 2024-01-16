import React from 'react'
import { useMutation } from '@tanstack/react-query'
import { sendRequest } from '@/utils/send-request'
import { typecheck } from '@/utils/typecheck'
import { redirectTo } from '@/utils/redirect-to'
import { SolutionForStudent } from '@/components/types'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { Modal, ModalProps } from './Modal'

const DEFAULT_ERROR = new Error('Unable to unpublish solution')

export const UnpublishSolutionModal = ({
  endpoint,
  ...props
}: ModalProps & { endpoint: string }): JSX.Element => {
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

      return fetch.then((json) =>
        typecheck<SolutionForStudent>(json, 'solution')
      )
    },
    {
      onSuccess: (solution) => {
        redirectTo(solution.privateUrl)
      },
    }
  )

  return (
    <Modal {...props} className="m-unpublish-solution">
      <h3>Do you want to unpublish your solution?</h3>
      <p>
        Unpublishing your solution will mean it no longer appears on your
        profile and can no longer be viewed under Community Solutions. All stars
        and comments will be lost, and any associated reputation will be
        removed.
      </p>

      <div className="btns">
        <FormButton
          type="button"
          onClick={() => mutation()}
          status={status}
          className="btn-primary btn-m"
        >
          Unpublish solution
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
