import React, { useCallback, useState } from 'react'
import { GraphicalIcon } from './GraphicalIcon'
import { setThemeClassName } from '../settings/ThemePreferenceForm'

export function ThemeToggleButton(): JSX.Element {
  const { currentColorScheme, switchToColorMode } = useSwitchTheme()

  return (
    <button
      onClick={(e) => {
        currentColorScheme === 'light'
          ? switchToColorMode(e, 'dark')
          : switchToColorMode(e, 'light')
      }}
    >
      <GraphicalIcon
        className="exercism-face"
        icon={`exercism-face${
          currentColorScheme === 'light' ? '-light' : '-dark'
        }`}
      />
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
