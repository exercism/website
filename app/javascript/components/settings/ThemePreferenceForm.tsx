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
  links,
}: {
  defaultThemePreference: string
  insidersStatus: string
  links: ThemePreferenceLinks
}): JSX.Element => {
  const { handleThemeUpdate } = useTheme(defaultThemePreference, links)
  const { theme } = useThemeObserver()

  return (
    <form data-turbo="false">
      <h2 className="!mb-4">Theme</h2>
      <InfoMessage
        insidersStatus={insidersStatus}
        insidersPath={links.insidersPath}
      />
      <div className="flex gap-32">
        {THEMES.map((t: Theme) => (
          <ThemeButton
            key={t.label}
            theme={t}
            currentTheme={theme.split('-')[1]}
            disabledInfo={isDisabled(insidersStatus, t.value)}
            onClick={(e) => handleThemeUpdate(t, e)}
          />
        ))}
      </div>
    </form>
  )
}
