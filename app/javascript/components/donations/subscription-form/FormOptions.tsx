import React, { useState, useCallback } from 'react'
import { InitializedOption } from './form-options/InitializedOption'
import { CancellingOption } from './form-options/CancellingOption'
import { UpdatingOption } from './form-options/UpdatingOption'

type FormStatus = 'initialized' | 'cancelling' | 'updating'

type Links = {
  cancel: string
  update: string
}

export const FormOptions = ({
  amountInDollars,
  links,
}: {
  amountInDollars: number
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
          amountInDollars={amountInDollars}
          onClose={handleInitialized}
          links={links}
        />
      )
    case 'cancelling':
      return <CancellingOption links={links} onClose={handleInitialized} />
  }
}
