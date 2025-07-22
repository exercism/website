// i18n-key-prefix: infoMessage
// i18n-namespace: components/settings/theme-preference-form
import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function InfoMessage({
  insidersStatus,
  insidersPath,
  isInsider,
}: {
  insidersStatus: string
  insidersPath: string
  isInsider: boolean
}): JSX.Element {
  const { t } = useAppTranslation('components/settings/theme-preference-form')
  if (isInsider) {
    return (
      <p className="text-p-base mb-16">
        {t('infoMessage.insiderAccessToDarkMode')}
      </p>
    )
  }

  switch (insidersStatus) {
    case 'eligible':
    case 'eligible_lifetime':
      return (
        <p className="text-p-base mb-16">
          <Trans
            i18nKey="infoMessage.eligibleToJoinInsiders"
            ns="components/settings/theme-preference-form"
            components={{ 0: <a href={insidersPath}></a> }}
          />
        </p>
      )
    default:
      return (
        <p className="text-p-base mb-16">
          <Trans
            i18nKey="infoMessage.darkModeOnlyAvailableToInsiders"
            ns="components/settings/theme-preference-form"
            components={{
              0: (
                <a className="text-prominentLinkColor" href={insidersPath}></a>
              ),
            }}
          />
        </p>
      )
  }
}
