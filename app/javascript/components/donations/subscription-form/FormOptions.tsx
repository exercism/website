import React, { useState, useCallback } from 'react'
import { InitializedOption } from './form-options/InitializedOption'
import { CancellingOption } from './form-options/CancellingOption'

type FormStatus = 'initialized' | 'cancelling'

type Links = {
  cancel: string
}

export const FormOptions = ({ links }: { links: Links }): JSX.Element => {
  const [status, setStatus] = useState<FormStatus>('initialized')

  const handleInitialized = useCallback(() => {
    setStatus('initialized')
  }, [])

  const handleCancelling = useCallback(() => {
    setStatus('cancelling')
  }, [])

  switch (status) {
    case 'initialized':
      return <InitializedOption onCancelling={handleCancelling} />
    case 'cancelling':
      return <CancellingOption links={links} onClose={handleInitialized} />
  }
}
