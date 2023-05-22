import React, { useCallback } from 'react'
import { useThemeObserver } from '@/hooks'
import { useTheme } from '../settings/theme-preference-form'
import { GenericTooltip } from '../misc/ExercismTippy'

export type ThemeToggleButtonProps = {
  disabled: boolean
  links: { update: string }
}

export function ThemeToggleButton({
  links,
  disabled,
}: ThemeToggleButtonProps): JSX.Element {
  const { binaryTheme } = useThemeObserver()
  const { handleThemeUpdate } = useTheme(binaryTheme?.split('-')[1], links)

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
      content="You need to be a Premium member to use this"
      disabled={!disabled}
    >
      <div>
        <button
          onClick={(e) => {
            binaryTheme === 'theme-light'
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
              checked={binaryTheme === 'theme-dark'}
            />
            <span className="slider round" />
          </label>
        </button>
      </div>
    </GenericTooltip>
  )
}
