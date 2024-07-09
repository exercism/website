let shouldToggleDarkThemeOnFullscreenChange = false

export function toggleDarkThemeOnFullscreenChange() {
  const fullscreenElement =
    document.fullscreenElement as HTMLIFrameElement | null
  const videoRegex =
    /^https?:\/\/(www\.)?(youtube\.com|player\.vimeo\.com)\/.*$/

  if (
    fullscreenElement &&
    videoRegex.test(fullscreenElement.src) &&
    document.body.classList.contains('theme-accessibility-dark')
  ) {
    document.body.classList.remove('theme-accessibility-dark')
    shouldToggleDarkThemeOnFullscreenChange = true
  } else if (!fullscreenElement && shouldToggleDarkThemeOnFullscreenChange) {
    document.body.classList.add('theme-accessibility-dark')
    shouldToggleDarkThemeOnFullscreenChange = false
  }
}

export function initializeFullscreenChangeListeners() {
  document.addEventListener(
    'fullscreenchange',
    toggleDarkThemeOnFullscreenChange
  )
  document.addEventListener(
    'webkitfullscreenchange',
    toggleDarkThemeOnFullscreenChange
  )
  document.addEventListener(
    'mozfullscreenchange',
    toggleDarkThemeOnFullscreenChange
  )
  document.addEventListener(
    'MSFullscreenChange',
    toggleDarkThemeOnFullscreenChange
  )
}
