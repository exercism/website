import * as acorn from 'acorn'

export function parseJS(code: string | undefined) {
  try {
    acorn.parse(code || '', {
      ecmaVersion: 2020,
      sourceType: 'module',
      locations: true,
    })
    return {
      status: 'success' as const,
    }
  } catch (err: any) {
    const loc = err.loc || { line: 1, column: 0 }
    return {
      status: 'error' as const,
      cleanup: () => {},
      error: {
        message: err.message.replace(/\s*\(\d+:\d+\)$/, ''),
        lineNumber: loc.line,
        colNumber: loc.column,
        type: err.name,
      },
    }
  }
}
