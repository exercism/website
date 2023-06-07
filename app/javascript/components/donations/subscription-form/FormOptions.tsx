import React, { useState, useCallback } from 'react'
import { InitializedOption } from './form-options/InitializedOption'
import { CancellingOption } from './form-options/CancellingOption'
import { UpdatingOption } from './form-options/UpdatingOption'
import currency from 'currency.js'

type FormStatus = 'initialized' | 'cancelling' | 'updating'

type Links = {
  cancel?: string
  update?: string
}

export const FormOptions = ({
  amount,
  links,
}: {
  amount: currency
  links: Links
}): JSX.Element | null => {
  const [status, setStatus] = useState<FormStatus>('initialized')

  const handleInitialized = useCallback(() => {
    setStatus('initialized')
  }, [])

  const handleCancelling = useCallback(() => {
    setStatus('cancelling')
  }, [])

  const handleUpdating = useCallback(() => {
    setStatus('updating')
  }, [])

  switch (status) {
    case 'initialized':
      return links.cancel || links.update ? (
        <InitializedOption
          onCancelling={handleCancelling}
          onUpdating={handleUpdating}
        />
      ) : null
    case 'updating':
      return links.update ? (
        <UpdatingOption
          amount={amount}
          onClose={handleInitialized}
          updateLink={links.update}
        />
      ) : null
    case 'cancelling':
      return links.cancel ? (
        <CancellingOption
          subscriptionType="donation"
          cancelLink={links.cancel}
          onClose={handleInitialized}
        />
      ) : null
  }
}
