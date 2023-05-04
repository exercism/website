import { useEffect, useState } from 'react'
import { Keybindings, Themes, EditorSettings } from './types'

export const useDefaultSettings = (settings: Partial<EditorSettings>) => {
  const [theme, setTheme] = useState<Themes>()
  useEffect(() => {
    const body = document.querySelector('body')
    const prefersDark =
      window.matchMedia &&
      window.matchMedia('(prefers-color-scheme: dark)').matches
    if (!body) return

    const currentTheme = body.classList.value.match(/theme-\S+/)?.[0]
    if (
      (currentTheme === 'theme-system' && prefersDark) ||
      currentTheme === 'theme-dark'
    ) {
      setTheme(Themes.DARK)
    }
    setTheme(Themes.LIGHT)
  }, [])

  return useState<EditorSettings>({
    theme: theme!,
    wrap: 'on',
    tabBehavior: 'captured',
    keybindings: Keybindings.DEFAULT,
    tabSize: 2,
    useSoftTabs: true,
    ...settings,
  })
}
