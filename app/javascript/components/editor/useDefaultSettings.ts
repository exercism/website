import { useState } from 'react'
import { Keybindings, Themes, EditorSettings } from './types'

function getThemeSetting() {
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
    return Themes.DARK
  } else return Themes.LIGHT
}

export const useDefaultSettings = (settings: Partial<EditorSettings>) => {
  return useState<EditorSettings>({
    theme: getThemeSetting()!,
    wrap: 'on',
    tabBehavior: 'captured',
    keybindings: Keybindings.DEFAULT,
    tabSize: 2,
    useSoftTabs: true,
    ...settings,
  })
}
