import { ConditionTextManager } from '@/utils/condition-text-manager'

export function setThemeClassName(theme: string): void {
  const themeData = grabCurrentTheme()
  if (!themeData) return

  const { body, currentTheme } = themeData
  const newTheme = `theme-${theme}`

  if (newTheme === currentTheme) {
    return
  }

  if (!currentTheme) {
    body.classList.add(newTheme)
  } else {
    body.classList.replace(currentTheme, newTheme)
  }
}

export function grabCurrentTheme():
  | {
      body: HTMLBodyElement
      currentTheme: string | undefined
    }
  | undefined {
  const body = document.querySelector('body')
  if (!body) return
  return { body, currentTheme: body.classList.value.match(/theme-\S+/)?.[0] }
}

export type isButtonDisabled = { level: string; disabled: boolean }
export function isDisabled(
  isInsider: boolean,
  theme: string,
  currentTheme: string
): isButtonDisabled {
  const disabledTheme = ['dark', 'system'].includes(theme)
  const selectedTheme = currentTheme === `theme-${theme}`

  const disabled = (!isInsider && disabledTheme) || selectedTheme

  const disabledLevel = new ConditionTextManager()
  disabledLevel.append(selectedTheme, 'selected')
  disabledLevel.append(!isInsider && disabledTheme, 'non-insider')

  return {
    level: disabledLevel.getLastTrueText() || 'enabled',
    disabled,
  }
}
