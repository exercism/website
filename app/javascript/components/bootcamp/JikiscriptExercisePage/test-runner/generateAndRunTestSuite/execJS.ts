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
      cleanup: () => {},
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
    }
  `
  code += `export function log(...args) { globalThis.customLog.call(null,...args) }\n`
  externalFunctionNames.forEach((fn) => {
    code += `export function ${fn}(...args) { globalThis.externalFunctions.${fn}.call(null, executionCtx, ...args) }\n`
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
    console.error('Logic error', error)

    // Extract line, and column from the error message string
    const [, lineNumber, colNumber] =
      error.stack?.match(/:(\d+):(\d+)\)?\s*$/m) || []

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
