import React from 'react'
import {
  InfoMessage,
  THEMES,
  ThemeButton,
  isDisabled,
  useTheme,
} from './theme-preference-form'
import { useThemeObserver } from '@/hooks'

export type ThemePreferenceLinks = {
  update: string
  insidersPath: string
  premiumPath: string
}

export type Theme = {
  label: string
  background: string
  icon: string
  value: string
}

export const ThemePreferenceForm = ({
  defaultThemePreference,
  insidersStatus,
  isPremium,
  links,
}: {
  defaultThemePreference: string
  insidersStatus: string
  isPremium: boolean
  links: ThemePreferenceLinks
}): JSX.Element => {
  const { handleThemeUpdate } = useTheme(defaultThemePreference, links)
  const { theme } = useThemeObserver()

  return (
    <form data-turbo="false">
      <h2 className="!mb-4">Theme</h2>
      <InfoMessage
        isPremium={isPremium}
        premiumPath={links.premiumPath}
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
            disabledInfo={isDisabled(isPremium, t.value, theme)}
            onClick={(e) => handleThemeUpdate(t, e)}
          />
        ))}
      </div>
    </form>
  )
}
