// i18n-key-prefix: themePreferenceForm
// i18n-namespace: components/settings/ThemePreferenceForm.tsx
import React from 'react'
import {
  InfoMessage,
  THEMES,
  ThemeButton,
  isDisabled,
  useTheme,
} from './theme-preference-form'
import { useThemeObserver } from '@/hooks/use-theme-observer'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type ThemePreferenceLinks = {
  update: string
  insidersPath: string
}

export type Theme = {
  label: string
  background: string
  icon: string
  value: string
}

export default function ThemePreferenceForm({
  defaultThemePreference,
  insidersStatus,
  links,
}: {
  defaultThemePreference: string
  insidersStatus: string
  links: ThemePreferenceLinks
}): JSX.Element {
  const { t } = useAppTranslation()
  const { handleThemeUpdate } = useTheme(defaultThemePreference, links)
  const { theme } = useThemeObserver()

  const isInsider =
    insidersStatus == 'active' || insidersStatus == 'active_lifetime'

  return (
    <form data-turbo="false">
      <h2 className="!mb-4">{t('themePreferenceForm.theme')}</h2>
      <InfoMessage
        isInsider={isInsider}
        insidersStatus={insidersStatus}
        insidersPath={links.insidersPath}
      />

      <div className="flex gap-32">
        {THEMES.map((t: Theme) => (
          <ThemeButton
            key={t.label}
            links={links}
            theme={t}
            currentTheme={theme.split('theme-')[1]}
            disabledInfo={isDisabled(isInsider, t.value, theme)}
            onClick={(e) => handleThemeUpdate(t, e)}
          />
        ))}
      </div>
    </form>
  )
}
