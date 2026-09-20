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
    // A full reload rather than swapping the language in place. Everything the
    // server already rendered for this request is in the old language: the
    // header, the nav, the page shell. Reloading re-resolves the whole page
    // against the preference the save just wrote, so the language changes
    // everywhere at once instead of in patches.
    onSuccess: () => window.location.reload(),
  })

  useEffect(() => {
    if (locale === defaultLocale) return

    mutation()
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [locale])

  return { locale, select: setLocale, status, error }
}
