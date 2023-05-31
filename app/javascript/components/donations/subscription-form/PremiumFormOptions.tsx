import React, { useState, useCallback } from 'react'
import { InitializedOption } from './form-options/PremiumInitializedOption'
import { CancellingOption } from './form-options/CancellingOption'
import currency from 'currency.js'

type PremiumFormStatus = 'initialized' | 'cancelling'

type Links = {
  cancel?: string
  update?: string
}

export const PremiumFormOptions = ({
  links,
}: {
  amount: currency
  links: Links
}): JSX.Element | null => {
  const [status, setStatus] = useState<PremiumFormStatus>('initialized')

  const handleInitialized = useCallback(() => {
    setStatus('initialized')
  }, [])

  const handleCancelling = useCallback(() => {
    setStatus('cancelling')
  }, [])

  switch (status) {
    case 'initialized':
      return links.cancel || links.update ? (
        <InitializedOption onCancelling={handleCancelling} />
      ) : null
    case 'cancelling':
      return links.cancel ? (
        <CancellingOption
          cancelLink={links.cancel}
          onClose={handleInitialized}
        />
      ) : null
  }
}
