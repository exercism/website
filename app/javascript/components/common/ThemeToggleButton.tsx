import React, { useCallback } from 'react'
import { useThemeObserver } from '@/hooks'
import { useTheme } from '../settings/theme-preference-form'

type Links = { links: { update: string } }

export function ThemeToggleButton({ links }: Links): JSX.Element {
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
    <button
      onClick={(e) => {
        binaryTheme === 'theme-light'
          ? switchToDarkTheme(e)
          : switchToLightTheme(e)
      }}
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
  )
}
