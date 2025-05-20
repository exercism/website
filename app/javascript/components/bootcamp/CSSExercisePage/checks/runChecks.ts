export type CheckResult = {
  result: boolean | null
  passes: boolean
  error_html: string | null
}

export type ChecksResult = {
  success: boolean
  results: CheckResult[]
}

export type Check = {
  function: string
  matcher: 'toBeTrue' | 'toBeFalse' | 'toBeUndefined'
  errorHtml: string
}

export function evaluateMatch(result: boolean, matcher: string): boolean {
  switch (matcher) {
    case 'toBeTrue':
      return result === true
    case 'toBeFalse':
      return result === false
    case 'toBeUndefined':
      return result === undefined || result === null

    default:
      throw new Error(`Unimplemented matcher: ${matcher}`)
  }
}

export async function runChecks(
  checks: Check[],
  value: string,
  checkFunctions: Record<string, Function>
): Promise<ChecksResult> {
  const resultPromises: Promise<CheckResult>[] = checks.map(async (check) => {
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
        args = argsString.trim().startsWith('(')
          ? safe_eval(`${argsString}`)
          : safe_eval(`(${argsString})`)
      } catch (error) {
        throw new Error(`Invalid arguments format: ${argsString}`)
      }

      const func = checkFunctions[funcName]
      if (!func) {
        throw new Error(`Function not found: ${funcName}`)
      }

      const result = await func(value, args)
      const passes = evaluateMatch(result, check.matcher)

      return {
        result,
        passes,
        error_html: passes
          ? null
          : check.errorHtml.replaceAll('%result%', result),
      }
    } catch (error: any) {
      return {
        result: null,
        passes: false,
        error_html: `Error evaluating check: ${error.message}`,
      }
    }
  })

  const results = await Promise.all(resultPromises)

  return {
    success: results.every((r) => r.passes),
    results,
  }
}
