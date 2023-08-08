import React, { useEffect } from 'react'
import { useQuery } from 'react-query'
import { redirectTo } from '@/utils'

export type PaymentPendingProps = {
  endpoint: string
  insidersRedirectPath: string
}

export function PaymentPending({
  endpoint,
  insidersRedirectPath,
}: PaymentPendingProps): JSX.Element {
  const fetchPaymentPending = async () => {
    const response = await fetch(endpoint)
    if (!response.ok) {
      throw new Error('Error fetching paypal status')
    }
    return response.json()
  }

  const { data } = useQuery('paypalStatus', fetchPaymentPending, {
    refetchInterval: 1000,
  })

  useEffect(() => {
    if (data && data.user.insiders) {
      redirectTo(insidersRedirectPath)
    }
  }, [data, insidersRedirectPath])

  return <div className="hidden"></div>
}
