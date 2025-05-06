import { numTagsUsed } from './html/numTagsUsed'
import { tagOccursNoMoreThan } from './html/tagOccursNoMoreThan'

export type HtmlCheck = {
  function: string
  matcher: 'toBeTrue' | 'toBeFalse'
  errorHtml: string
}

export type CheckResult = {
  result: boolean | null
  passes: boolean
  error_html: string | null
}

export type ChecksResult = {
  success: boolean
  results: CheckResult[]
}

const checkFunctions: Record<string, Function> = {
  tagOccursNoMoreThan,
  numTagsUsed,
}

function evaluateMatch(result: boolean, matcher: string): boolean {
  switch (matcher) {
    case 'toBeTrue':
      return result === true
    case 'toBeFalse':
      return result === false
    default:
      throw new Error(`Unimplemented matcher: ${matcher}`)
  }
}

export function runHtmlChecks(
  checks: Check[],
  htmlValue: string
): ChecksResult {
  const results: CheckResult[] = checks.map((check) => {
    try {
      const funcMatch = check.function.match(/([a-zA-Z0-9_]+)\((.*)\)/)

      if (!funcMatch) {
        throw new Error(`Invalid function format: ${check.function}`)
      }

      const funcName = funcMatch[1]
      const argsString = funcMatch[2]
      let args: any

      try {
        const safe_eval = eval
        args = safe_eval(`(${argsString})`)
      } catch (error) {
        throw new Error(`Invalid arguments format: ${argsString}`)
      }

      const func = checkFunctions[funcName]
      if (!func) {
        throw new Error(`Function not found: ${funcName}`)
      }

      const result = func(htmlValue, args)
      const passes = evaluateMatch(result, check.matcher)

      return {
        result,
        passes,
        error_html: passes ? null : check.errorHtml,
      }
    } catch (error: any) {
      return {
        result: null,
        passes: false,
        error_html: `Error evaluating check: ${error.message}`,
      }
    }
  })

  return {
    success: results.every((r) => r.passes),
    results,
  }
}
