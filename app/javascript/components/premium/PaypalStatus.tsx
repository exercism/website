import React, { useEffect } from 'react'
import { useQuery } from 'react-query'
import { redirectTo } from '@/utils'

export type PaypalStatusProps = {
  endpoint: string
  premiumRedirectPath: string
}

export function PaypalStatus({
  endpoint,
  premiumRedirectPath,
}: PaypalStatusProps): JSX.Element {
  const fetchPaypalStatus = async () => {
    const response = await fetch(endpoint)
    if (!response.ok) {
      throw new Error('Error fetching paypal status')
    }
    return response.json()
  }

  const { data } = useQuery('paypalStatus', fetchPaypalStatus, {
    refetchInterval: 1000,
  })

  useEffect(() => {
    if (data && data.user.premium) {
      redirectTo(premiumRedirectPath)
    }
  }, [data, premiumRedirectPath])

  return <div className="hidden"></div>
}
