import { parse } from 'parse5'
import { checkNesting } from './rules/checkNesting'
import { walkDom } from './rules/walkDom'
import { checkVoidTagClosure } from './rules/checkVoidTagClosure'

export function validateHtml5(html: string): {
  isValid: boolean
  errorMessage?: string
} {
  try {
    const document = parse(html, { sourceCodeLocationInfo: true })

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
      checkNesting(html)
    } catch (err) {
      return {
        isValid: false,
        errorMessage: (err as Error).message,
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

    const walkResult = walkDom(document)
    if (!walkResult.success) {
      return {
        isValid: false,
        errorMessage: walkResult.message,
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
