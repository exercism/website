import React, { useState, useCallback } from 'react'
import { InitializedOption } from './form-options/InitializedOption'
import { CancellingOption } from './form-options/CancellingOption'
import { UpdatingOption } from './form-options/UpdatingOption'
import currency from 'currency.js'

type FormStatus = 'initialized' | 'cancelling' | 'updating'

type Links = {
  cancel: string
  update: string
}

export const FormOptions = ({
  amount,
  links,
}: {
  amount: currency
  links: Links
}): JSX.Element => {
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
      return (
        <InitializedOption
          onCancelling={handleCancelling}
          onUpdating={handleUpdating}
        />
      )
    case 'updating':
      return (
        <UpdatingOption
          amount={amount}
          onClose={handleInitialized}
          links={links}
        />
      )
    case 'cancelling':
      return <CancellingOption links={links} onClose={handleInitialized} />
  }
}
