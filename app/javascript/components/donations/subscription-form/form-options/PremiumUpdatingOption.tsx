import React, { useCallback } from 'react'
import { useMutation } from 'react-query'
import { sendRequest, typecheck, redirectTo } from '@/utils'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { PremiumPlan } from '../../PremiumSubscriptionForm'
import { FormButton } from '@/components/common'

type APIResponse = {
  links: {
    index: string
  }
}

const DEFAULT_ERROR = new Error('Unable to update subscription')

export const PremiumUpdatingOption = ({
  updateLink,
  otherPlan,
  onClose,
}: {
  otherPlan: PremiumPlan
  updateLink: string
  onClose: () => void
}): JSX.Element => {
  const [mutation, { status, error }] = useMutation<APIResponse>(
    async () => {
      const { fetch } = sendRequest({
        endpoint: updateLink,
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
      <form data-turbo="false" onSubmit={handleSubmit}>
        <p className="text-p-base">
          Are you sure you want to change to {otherPlan.description}?
        </p>
        <p className="footnote">
          You&apos;ll start being charged&nbsp;
          <strong>
            {otherPlan.amount}&nbsp;
            {otherPlan.type === 'month' ? 'per month' : 'annually'}
          </strong>
          , on your next billing date.
        </p>
        <div className="flex">
          <FormButton status={status} className="btn-xs btn-primary mr-12">
            Yes
          </FormButton>
          <FormButton
            type="button"
            onClick={onClose}
            status={status}
            className="btn-xs btn-enhanced"
          >
            Cancel this change
          </FormButton>
        </div>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </div>
  )
}
