import { useState } from 'react'
import { Keybindings, Themes, EditorSettings } from './types'

export const useDefaultSettings = (settings: Partial<EditorSettings>) => {
  return useState<EditorSettings>({
    theme: Themes.LIGHT,
    wrap: 'on',
    tabBehavior: 'captured',
    keybindings: Keybindings.DEFAULT,
    tabSize: 2,
    useSoftTabs: true,
    ...settings,
  })
}
