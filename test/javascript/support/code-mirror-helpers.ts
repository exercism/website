export function stubRange(): void {
  document.createRange = () => {
    const range = new Range()

    range.getBoundingClientRect = jest.fn()

    range.getClientRects = () => {
      return {
        item: () => null,
        length: 0,
        [Symbol.iterator]: jest.fn(),
      }
    }

    return range
  }
  window.focus = jest.fn()
}
