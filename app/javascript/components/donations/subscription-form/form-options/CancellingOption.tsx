import React, { useCallback } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { typecheck } from '../../../../utils/typecheck'
import { redirectTo } from '../../../../utils/redirect-to'
import { FormButton } from '../../../common'
import { ErrorBoundary, ErrorMessage } from '../../../ErrorBoundary'

type Links = {
  cancel: string
}

type APIResponse = {
  links: {
    index: string
  }
}

const DEFAULT_ERROR = new Error('Unable to cancel subscription')

export const CancellingOption = ({
  links,
  onClose,
}: {
  links: Links
  onClose: () => void
}): JSX.Element => {
  const [mutation, { status, error }] = useMutation<APIResponse>(
    () => {
      const { fetch } = sendRequest({
        endpoint: links.cancel,
        method: 'PATCH',
        body: null,
      })

      return fetch.then((json) => typecheck<APIResponse>(json, 'subscription'))
    },
    {
      onSuccess: (response) => {
        redirectTo(response.links.index)
      },
    }
  )

  const handleCancel = useCallback(() => {
    mutation()
  }, [mutation])

  return (
    <div className="options">
      <p>Are you sure you want to cancel your recurring donation?</p>
      <FormButton type="button" onClick={handleCancel} status={status}>
        Yes - please cancel it.
      </FormButton>
      <FormButton type="button" onClick={onClose} status={status}>
        No, close this.
      </FormButton>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </div>
  )
}
