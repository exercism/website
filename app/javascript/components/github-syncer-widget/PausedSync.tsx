import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

// Syncer disabled: "Your syncer is currently disabled. Visit your settings (LINK <<) to enable it"
export function PausedSync({
  settingsLink,
}: {
  settingsLink: string
}): JSX.Element {
  const { t } = useAppTranslation('components/github-syncer-widget')
  return (
    <div className="flex flex-col items-center py-24">
      <h6 className="font-semibold text-16 mb-16">
        <Trans
          i18nKey="pausedSync.visitSettingsToResumeSyncing"
          ns="components/github-syncer-widget"
          components={[<span className="text-orange" />]}
        />
      </h6>
      <p className="text-center text-balance">
        <Trans
          i18nKey="pausedSync.visitSettingsToResumeSyncing"
          ns="components/github-syncer-widget"
          components={[
            <a href={settingsLink} className="text-prominentLinkColor" />,
          ]}
        />
      </p>
    </div>
  )
}
