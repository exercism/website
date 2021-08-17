class LoadingOverlay {
  element: HTMLDivElement

  constructor() {
    const element = document.querySelector<HTMLDivElement>('.c-loading-overlay')

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
    Turbo: typeof import('@hotwired/turbo/dist/types/core/index')
  }
}

export const redirectTo = (url: string): void => {
  window.Turbo.visit(url)

  new LoadingOverlay().show()
}

export const bindRedirectEvents = (): void => {
  document.addEventListener('turbolinks:load', () => {
    new LoadingOverlay().hide()
  })
}
