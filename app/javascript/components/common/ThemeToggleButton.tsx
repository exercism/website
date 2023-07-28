import React, { useCallback } from 'react'
import { useThemeObserver } from '@/hooks'
import { useTheme } from '../settings/theme-preference-form'
import { GenericTooltip } from '../misc/ExercismTippy'

export type ThemeToggleButtonProps = {
  disabled: boolean
  defaultTheme: string
  links: { update: string; premium: string }
}

export function ThemeToggleButton({
  links,
  disabled,
  defaultTheme,
}: ThemeToggleButtonProps): JSX.Element {
  const { explicitTheme } = useThemeObserver(links.update)
  const { handleThemeUpdate } = useTheme(defaultTheme, links)

  const switchToDarkTheme = useCallback(
    (e) => {
      handleThemeUpdate({ value: 'dark' }, e)
    },
    [handleThemeUpdate]
  )
  const switchToLightTheme = useCallback(
    (e) => {
      handleThemeUpdate({ value: 'light' }, e)
    },
    [handleThemeUpdate]
  )

  return (
    <GenericTooltip
      content={<DisabledThemeSelectorTooltip premiumLink={links.premium} />}
      placement="bottom"
      interactive
      disabled={!disabled}
    >
      {/* 24 is the padding of nav-elements' label */}
      <div className="ml-24">
        <button
          onClick={(e) => {
            explicitTheme === 'theme-light' || explicitTheme === 'theme-sepia'
              ? switchToDarkTheme(e)
              : switchToLightTheme(e)
          }}
          disabled={disabled}
          className="toggle-button"
        >
          <label className="switch">
            <input
              type="checkbox"
              readOnly
              checked={
                explicitTheme === 'theme-dark' ||
                explicitTheme === 'theme-accessibility-dark'
              }
            />
            <span className="slider round" />
          </label>
        </button>
      </div>
    </GenericTooltip>
  )
}

export function DisabledThemeSelectorTooltip({
  premiumLink,
}: {
  premiumLink: string
}): JSX.Element {
  return (
    <div className="flex text-14 font-medium">
      <a className="text-14 text-[#F7B000] underline" href={premiumLink}>
        Join Premium
      </a>
      &nbsp;to enable Dark Mode
    </div>
  )
}
