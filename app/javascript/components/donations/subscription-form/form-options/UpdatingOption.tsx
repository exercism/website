import React, { useCallback, useState } from 'react'
import { useMutation } from '@tanstack/react-query'
import currency from 'currency.js'
import { typecheck, redirectTo } from '@/utils'
import { sendRequest } from '@/utils/send-request'
import { FormButton } from '@/components/common/FormButton'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'

type APIResponse = {
  links: {
    index: string
  }
}

const DEFAULT_ERROR = new Error('Unable to update subscription')

export const UpdatingOption = ({
  amount: currentAmount,
  updateLink,
  onClose,
}: {
  amount: currency
  updateLink: string
  onClose: () => void
}): JSX.Element => {
  const [amount, setAmount] = useState<currency | ''>(currentAmount)

  const {
    mutate: mutation,
    status,
    error,
  } = useMutation<APIResponse>(
    async () => {
      if (amount === '') {
        throw 'cant change to empty amount'
      }

      const { fetch } = sendRequest({
        endpoint: updateLink,
        method: 'PATCH',
        body: JSON.stringify({ amount_in_cents: amount.intValue }),
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
    const parsedValue = parseInt(e.target.value)

    if (isNaN(parsedValue)) {
      setAmount('')
      return
    }

    if (Math.sign(parsedValue) !== 1) {
      setAmount('')
      return
    }

    setAmount(currency(e.target.value))
  }, [])

  return (
    <div className="expanded-option">
      <form data-turbo="false" onSubmit={handleSubmit}>
        <label htmlFor="donation_amount" className="text-label">
          Change donation amount
        </label>
        <label className="c-faux-input">
          <div className="icon">$</div>
          <input
            type="number"
            min="0"
            step="0.01"
            id="donation_amount"
            value={amount === '' ? amount : amount.value}
            onChange={handleChange}
          />
        </label>
        {amount !== '' ? (
          <React.Fragment>
            <p className="footnote">
              You&apos;ll start being charged{' '}
              <strong>{amount.format()} per month</strong>, on your next billing
              date.
              {amount.value > currentAmount.value
                ? ' Thank you for increasing your donation!'
                : null}
            </p>
          </React.Fragment>
        ) : null}
        <div className="flex">
          <FormButton
            status={status}
            disabled={amount === ''}
            className="btn-xs btn-primary mr-12"
          >
            Change amount
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
