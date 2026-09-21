import { useEffect, useState } from 'react'
import type { MutationStatus } from '@tanstack/react-query'
import { useSettingsMutation } from '../useSettingsMutation'

type RequestBody = {
  language: {
    locale: string
  }
}

type UseLanguageFieldReturns = {
  locale: string
  select: (locale: string) => void
  status: MutationStatus
  error: unknown
}

export function useLanguageField(
  defaultLocale: string,
  endpoint: string
): UseLanguageFieldReturns {
  const [locale, setLocale] = useState(defaultLocale)

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint,
    method: 'PATCH',
    body: { language: { locale } },
    onSuccess: () => window.location.reload(),
  })

  useEffect(() => {
    if (locale === defaultLocale) return

    mutation()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [locale])

  return { locale, select: setLocale, status, error }
}
