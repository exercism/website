import { generateCodeRunString } from '../../utils/generateCodeRunString'
import * as acorn from 'acorn'

const esm = (code: string) =>
  URL.createObjectURL(new Blob([code], { type: 'text/javascript' }))

type ExecSuccess = {
  status: 'success'
  result: any
  cleanup: () => void
}
type ExecError = {
  status: 'error'
  error: {
    type: string
    message: string
    lineNumber: number
    colNumber: number
  }
  cleanup: () => void
}
type ExecResult = ExecSuccess | ExecError

export async function execJS(
  studentCode: string,
  fnName: string,
  args: any[],
  externalFunctionNames: string[]
): Promise<ExecResult> {
  // First, look for parse-errors, which we have to do via acorn to get line/col numbers.
  try {
    acorn.parse(studentCode, { ecmaVersion: 2020, sourceType: 'module' })
  } catch (err: any) {
    return {
      status: 'error',
      cleanup: () => { },
      error: {
        message: err.message.replace(/\s*\(\d+:\d+\)$/, ''),
        lineNumber: err.loc.line - 1, // No idea why we are 2 out.
        colNumber: err.loc.column,
        type: err.name,
      },
    }
  }

  let code = `
    let currentTime = 0
    const executionCtx = { 
      getCurrentTime: () => currentTime, 
      fastForward: (time) => { currentTime += time },
      updateState: () => {},
      logicError: (e) => { globalThis.logicError(e) },
    }
  `
  code += `export function log(...args) { globalThis.customLog.call(null,...args) }\n`
  externalFunctionNames.forEach((fn) => {
    code += `export function ${fn}(...args) { return globalThis.externalFunctions.${fn}.call(null, executionCtx, ...args) }\n`
  })
  const numSetupLines = code.split('\n').length
  code += studentCode

  const importableStudentCode = esm(code)
  const importableTestCode = esm(`
    import { ${fnName} } from '${importableStudentCode}'
    export default ${generateCodeRunString(fnName, args)}
  `)

  function cleanup() {
    URL.revokeObjectURL(importableStudentCode)
    URL.revokeObjectURL(importableTestCode)
  }

  try {
    const result = await import(`${importableTestCode}`)
    const successResult: ExecSuccess = {
      status: 'success',
      result: result.default,
      cleanup,
    }
    return successResult
  } catch (error: any) {
    let lineNumber: string
    let colNumber: string

    if (error.name === 'JikiLogicError') {
      ;[, lineNumber, colNumber] = extractLineColFromJikiLogicError(error)
    } else {
      // Extract line, and column from the error message string
      ;[, lineNumber, colNumber] =
        error.stack?.match(/:(\d+):(\d+)\)?\s*$/m) || []
    }
    if (error.message.includes('does not provide an export')) {
      error.message = `Oh dear, we couldn't find \`${fnName}\`. Did you forget to \`export\` it?`
    }

    const execError: ExecError = {
      status: 'error',
      error: {
        type: error.name,
        message: error.message,
        lineNumber: lineNumber ? parseInt(lineNumber) - numSetupLines : 0,
        colNumber: colNumber ? parseInt(colNumber) : 0,
      },
      cleanup,
    }
    return execError
  }
}

function extractLineColFromJikiLogicError(error) {
  const stack = error.stack || ''

  const lines = stack.split('\n')
  const index = lines.findIndex((line) =>
    line.includes('JikiscriptExercisePage')
  )
  const targetLine = lines[index + 2]

  if (!targetLine) return null

  const match = targetLine.match(/:(\d+):(\d+)\)?\s*$/)
  if (!match) return null

  return match
}
