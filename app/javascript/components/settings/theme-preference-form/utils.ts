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

function grabCurrentTheme():
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
  insidersStatus: string,
  theme: string
): isButtonDisabled {
  const active = ['active', 'active_lifetime'].includes(insidersStatus)
  const disabledTheme = ['dark', 'system'].includes(theme)
  const themeData = grabCurrentTheme()
  const currentTheme = themeData ? themeData.currentTheme : ''
  const selectedTheme = currentTheme === `theme-${theme}`

  const disabled = (!active && disabledTheme) || selectedTheme

  const disabledIndex =
    Math.max(Number(selectedTheme) * 1, Number(!active && disabledTheme) * 2) -
    1

  return {
    level: ['selected', 'non-insider'][disabledIndex] || 'enabled',
    disabled,
  }
}
