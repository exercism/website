// i18n-key-prefix: paymentPending
// i18n-namespace: components/insiders
import React, { useEffect } from 'react'
import { camelizeKeys } from 'humps'
import { useQuery } from '@tanstack/react-query'
import { redirectTo } from '@/utils'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type PaymentPendingProps = {
  endpoint: string
  insidersRedirectPath: string
}

export default function PaymentPending({
  endpoint,
  insidersRedirectPath,
}: PaymentPendingProps): JSX.Element {
  const { t } = useAppTranslation('components/insiders')
  const fetchPaymentPending = async () => {
    const response = await fetch(endpoint)
    if (!response.ok) {
      throw new Error(t('paymentPending.errorFetchingStatus'))
    }
    return response.json()
  }

  const { data } = useQuery(['paypalStatus'], fetchPaymentPending, {
    refetchInterval: 1000,
  })

  useEffect(() => {
    if (!data) {
      return
    }

    const insidersStatus = camelizeKeys(data.user).insidersStatus
    if (insidersStatus == 'active' || insidersStatus == 'active_lifetime') {
      redirectTo(insidersRedirectPath)
    }
  }, [data, insidersRedirectPath])

  return <div className="hidden"></div>
}
