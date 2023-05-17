import React, { useCallback, useState } from 'react'
import { setThemeClassName } from '../settings/theme-preference-form/utils'

export function ThemeToggleButton(): JSX.Element {
  const { currentColorScheme, switchToColorMode } = useSwitchTheme()

  return (
    <button
      className="toggle-button"
      onClick={(e) => {
        currentColorScheme === 'light'
          ? switchToColorMode(e, 'dark')
          : switchToColorMode(e, 'light')
      }}
    >
      <label className="switch">
        <input type="checkbox" checked={currentColorScheme === 'dark'} />
        <span className="slider round" />
      </label>
    </button>
  )
}

function useSwitchTheme() {
  const [currentColorScheme, setCurrentColorScheme] = useState(
    window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light'
  )

  const switchToColorMode = useCallback((e, mode) => {
    e.preventDefault()
    setThemeClassName(mode)
    setCurrentColorScheme(mode)
  }, [])

  return { currentColorScheme, switchToColorMode }
}
