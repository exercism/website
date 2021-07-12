import Turbolinks from 'turbolinks'

class LoadingOverlay {
  element: HTMLDivElement

  constructor() {
    const element = document.querySelector<HTMLDivElement>('.loading-overlay')

    if (element === null) {
      throw new Error('No loading overlay found!')
    }

    this.element = element
  }

  static get displayClass() {
    return '--loading'
  }

  show() {
    this.element.classList.add(LoadingOverlay.displayClass)
  }

  hide() {
    this.element.classList.remove(LoadingOverlay.displayClass)
  }
}

declare global {
  interface Window {
    Turbolinks: Turbolinks.TurbolinksStatic
  }
}

export const redirectTo = (url: string): void => {
  window.Turbolinks.visit(url)

  new LoadingOverlay().show()
}

export const bindRedirectEvents = (): void => {
  document.addEventListener('turbolinks:load', () => {
    new LoadingOverlay().hide()
  })
}
