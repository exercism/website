export function toggleDarkThemeOnFullscreenChange() {
  const fullscreenElement = document.fullscreenElement
  const youtubeIframe = document.querySelector('iframe')

  if (
    fullscreenElement === youtubeIframe &&
    document.body.classList.contains('theme-accessibility-dark')
  ) {
    document.body.classList.remove('theme-accessibility-dark')
  } else {
    document.body.classList.add('theme-accessibility-dark')
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
