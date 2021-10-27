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

export const redirectTo = (url: string): void => {
  window.Turbo.visit(url)

  new LoadingOverlay().show()
}
