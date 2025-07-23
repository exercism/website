// i18n-key-prefix: handle
// i18n-namespace: components/track/activity-ticker
import React from 'react'
import type { MetricUser } from '@/components/types'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function Handle({
  user,
  countryName,
}: {
  user?: MetricUser
  countryName: string
}) {
  const { t } = useAppTranslation('components/track/activity-ticker')
  if (!user)
    return countryName
      ? t('handle.someoneInCountry', { countryName })
      : t('handle.someone')

  const { handle, links } = user

  return links?.self ? (
    <a href={links.self} className="text-prominentLinkColor font-semibold">
      {handle}
    </a>
  ) : (
    <span className="font-semibold">{handle}</span>
  )
}
