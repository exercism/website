import React from 'react'
import { FormMessage } from './FormMessage'
import {
  InfoMessage,
  THEMES,
  ThemeButton,
  isDisabled,
  useTheme,
} from './theme-preference-form'
import { Icon } from '../common'

export type ThemePreferenceLinks = {
  update: string
  insidersPath: string
}

export type Theme = {
  label: string
  background: string
  iconFilter: string
  value: string
}

const DEFAULT_ERROR = new Error('Unable to update theme preference')

export const ThemePreferenceForm = ({
  defaultThemePreference,
  insidersStatus,
  links,
}: {
  defaultThemePreference: string
  insidersStatus: string
  links: ThemePreferenceLinks
}): JSX.Element => {
  const { theme, handleThemeUpdate, status, error } = useTheme(
    defaultThemePreference,
    links
  )

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
            currentTheme={theme}
            disabledInfo={isDisabled(insidersStatus, t.value)}
            onClick={() => handleThemeUpdate(t)}
          />
        ))}
      </div>
      <div className="form-footer min-h-[80px]">
        <FormMessage
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
          SuccessMessage={() => <SuccessMessage />}
        />
      </div>
    </form>
  )
}

const SuccessMessage = () => {
  return (
    <div className="status success">
      <Icon icon="completed-check-circle" alt="Success" />
      Your theme has been updated!
    </div>
  )
}
