import { ExternalFunction } from '@/interpreter/executor'
import { generateCodeRunString } from '../../utils/generateCodeRunString'
import * as acorn from 'acorn'
import { c } from '@codemirror/legacy-modes/mode/clike'

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
  try {
    acorn.parse(studentCode, { ecmaVersion: 2020, sourceType: 'module' })
    const blob = new Blob([studentCode], { type: 'text/javascript' })
    const url = URL.createObjectURL(blob)
    await import(url)
  } catch (err: any) {
    return {
      status: 'error',
      cleanup: () => {},
      error: {
        message: err.message.replace(/\s*\(\d+:\d+\)$/, ''),
        lineNumber: err.loc.line - 3, // No idea why we are 3 out.
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
  externalFunctionNames.forEach((fn) => {
    code += `export function ${fn}(...args) { console.log(executionCtx); globalThis.externalFunctions.${fn}.call(null, executionCtx, ...args) }\n`
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

  return import(`${importableTestCode}`)
    .then((result) => {
      return { status: 'success', result: result.default, cleanup }
    })
    .catch((error: Error) => {
      console.log('Logic error', error)

      // Extract line, and column from the error message string
      const [, lineNumber, colNumber] =
        error.stack?.match(/:(\d+):(\d+)\)?\s*$/m) || []

      // console.log(type, message, line, col)
      return {
        status: 'error',
        error: {
          type: error.name,
          message: error.message,
          lineNumber: lineNumber ? parseInt(lineNumber) - numSetupLines : 0,
          colNumber: colNumber ? parseInt(colNumber) : 0,
        },
        cleanup,
      }
    })
}
