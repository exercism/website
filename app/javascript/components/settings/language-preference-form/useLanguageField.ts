import { useCallback, useEffect, useState } from 'react'
import type { MutationStatus } from '@tanstack/react-query'
import { useSettingsMutation } from '../useSettingsMutation'
import { setLocalePrefCookie } from '@/utils/locale-pref-cookie'

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

  // Signed-in pages use the saved locale. The cookie keeps the choice for the
  // signed-out pages this browser sees after signing out.
  const select = useCallback((code: string) => {
    setLocalePrefCookie(code)
    setLocale(code)
  }, [])

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint,
    method: 'PATCH',
    body: { language: { locale } },
    // A signed-in user's URLs carry no locale prefix, so reloading the same
    // page renders it in the newly saved locale.
    onSuccess: () => window.location.reload(),
  })

  useEffect(() => {
    if (locale === defaultLocale) return

    mutation()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [locale])

  return { locale, select, status, error }
}
