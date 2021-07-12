import React, { useCallback, useState } from 'react'
import { GenericForm } from './GenericForm'

export function OneOffForm({}: {}) {
  return (
    <>
      <h2>One off!</h2>
      <GenericForm
        paymentIntentEndpoint={'/api/v2/donations/payments'}
        onSuccess={() => {}}
      />
    </>
  )
}
