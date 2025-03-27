import { generateCodeRunString } from '../../utils/generateCodeRunString'

const esm = (code: string) =>
  URL.createObjectURL(new Blob([code], { type: 'text/javascript' }))

export async function execJS(
  code: string,
  fnName: string,
  args: any[]
): Promise<{
  result?: any
  message?: string
  cleanup: () => void
}> {
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
      return { result: result.default, cleanup }
    })
    .catch((error) => {
      return { ...{ message: error.message }, cleanup }
    })
}
