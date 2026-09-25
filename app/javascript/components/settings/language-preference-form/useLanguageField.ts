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
  endpoint: string,
  redirectPathFor: (locale: string) => string | undefined
): UseLanguageFieldReturns {
  const [locale, setLocale] = useState(defaultLocale)

  // Set on choosing, not on arriving: the cookie outranks both the path and a
  // save the next page may not have read back yet.
  const select = useCallback((code: string) => {
    setLocalePrefCookie(code)
    setLocale(code)
  }, [])

  const { mutation, status, error } = useSettingsMutation<RequestBody>({
    endpoint,
    method: 'PATCH',
    body: { language: { locale } },
    // A locale in the path outranks the saved preference.
    onSuccess: () => {
      const path = redirectPathFor(locale)

      if (path && path !== window.location.pathname + window.location.search) {
        window.location.assign(path)
      } else {
        window.location.reload()
      }
    },
  })

  useEffect(() => {
    if (locale === defaultLocale) return

    mutation()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [locale])

  return { locale, select, status, error }
}
