import { checkNesting } from './rules/checkNesting'
import { checkVoidTagClosure } from './rules/checkVoidTagClosure'

export function validateHtml5(html: string): {
  isValid: boolean
  errorMessage?: string
} {
  try {
    if (html.includes('<') && !html.includes('>')) {
      return {
        isValid: false,
        errorMessage: 'Unclosed angle bracket',
      }
    }

    if (html.match(/<[^>]*$/)) {
      return {
        isValid: false,
        errorMessage: 'Unclosed tag at end of document',
      }
    }

    try {
      checkVoidTagClosure(html)
    } catch (err) {
      return {
        isValid: false,
        errorMessage: (err as Error).message,
      }
    }

    try {
      checkNesting(html)
    } catch (err) {
      return {
        isValid: false,
        errorMessage: (err as Error).message,
      }
    }

    return { isValid: true }
  } catch (err) {
    return {
      isValid: false,
      errorMessage: (err as Error).message || 'Unknown error',
    }
  }
}
