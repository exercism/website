import React, { useCallback, useState } from 'react'
import { useMutation } from 'react-query'
import { sendRequest } from '../../../../utils/send-request'
import { typecheck } from '../../../../utils/typecheck'
import { redirectTo } from '../../../../utils/redirect-to'
import { FormButton } from '../../../common'
import { ErrorBoundary, ErrorMessage } from '../../../ErrorBoundary'
import currency from 'currency.js'

type Links = {
  update: string
}

type APIResponse = {
  links: {
    index: string
  }
}

const DEFAULT_ERROR = new Error('Unable to update subscription')

export const UpdatingOption = ({
  amountInDollars: currentAmountInDollars,
  links,
  onClose,
}: {
  amountInDollars: number
  links: Links
  onClose: () => void
}): JSX.Element => {
  const [amountInDollars, setAmountInDollars] = useState<number | ''>(
    currentAmountInDollars
  )

  const [mutation, { status, error }] = useMutation<APIResponse>(
    () => {
      const { fetch } = sendRequest({
        endpoint: links.update,
        method: 'PATCH',
        body: JSON.stringify({ amount_in_dollars: amountInDollars }),
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

  const handleChange = useCallback((e) => {
    const amount = parseInt(e.target.value)

    if (isNaN(amount)) {
      setAmountInDollars('')

      return
    }

    setAmountInDollars(amount)
  }, [])

  console.log(amountInDollars)

  return (
    <div className="options">
      <form onSubmit={handleSubmit}>
        <label htmlFor="donation_amount">Change donation amount</label>
        <label className="c-faux-input">
          <div className="icon">$</div>
          <input
            type="number"
            min="0"
            step="1"
            id="donation_amount"
            value={amountInDollars}
            onChange={handleChange}
          />
        </label>
        {amountInDollars !== '' ? (
          <React.Fragment>
            <p>
              You&apos;ll start being charged{' '}
              {currency(amountInDollars, { precision: 2 }).format()} per month,
              on your next billing date.
            </p>
            {amountInDollars > currentAmountInDollars ? (
              <p>Thanks for increasing your donation</p>
            ) : null}
          </React.Fragment>
        ) : null}
        <FormButton status={status} disabled={amountInDollars === ''}>
          Change
        </FormButton>
        <FormButton type="button" onClick={onClose} status={status}>
          Close
        </FormButton>
      </form>
      <ErrorBoundary resetKeys={[status]}>
        <ErrorMessage error={error} defaultError={DEFAULT_ERROR} />
      </ErrorBoundary>
    </div>
  )
}
