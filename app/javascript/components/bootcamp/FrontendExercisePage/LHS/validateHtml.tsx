export function validateHtml(html: string): {
  isValid: boolean
  errorMessage?: string
} {
  try {
    const doc = new DOMParser().parseFromString(html, 'application/xml')
    const parserError = doc.querySelector('parsererror')

    if (parserError) {
      const errorMessage =
        parserError.textContent?.trim() || 'Unknown parser error'
      return { isValid: false, errorMessage }
    }

    return { isValid: true }
  } catch (err) {
    return {
      isValid: false,
      errorMessage: (err as Error).message || 'Unknown error',
    }
  }
}
