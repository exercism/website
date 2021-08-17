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

  const handleSubmit = useCallback(
    (e) => {
      e.preventDefault()

      mutation()
    },
    [mutation]
  )

  return (
    <div className="expanded-option">
      <p className="text-p-base">
        Are you sure you want to cancel your recurring donation?
      </p>
      <form data-turbo="false" onSubmit={handleSubmit}>
        <div className="flex">
          <FormButton status={status} className="btn-xs btn-primary mr-12">
            Yes - please cancel it.
          </FormButton>
          <FormButton
            type="button"
            onClick={onClose}
            status={status}
            className="btn-xs btn-enhanced"
          >
            No, close this.
          </FormButton>
        </div>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </div>
  )
}
