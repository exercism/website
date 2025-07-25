export type ParsedLLMResult = {
  translations: Record<string, string>
  modifiedFiles: Record<string, string>
  namespace: string | undefined
}

export function sanitizeBadJsObject(input: string): string {
  return input
    .replace(/^```(json|js)?\s*/i, '')
    .replace(/```$/, '')
    .replace(/\r\n/g, '\n')
    .replace(/\\(?!["'\\bfnrtu])/g, '\\\\') // escape bad backslashes
    .replace(/\\…/g, '…') // common LLM bug
    .replace(/[\u0000-\u001F]+/g, '') // remove control chars
    .trim()
}

export function parseLLMOutputHaml(output: string): ParsedLLMResult {
  let jsStr = output.trim()

  if (jsStr.startsWith('```')) {
    const match = jsStr.match(/```(?:json|js)?\s*([\s\S]+?)\s*```/)
    if (match) {
      jsStr = match[1].trim()
    } else {
      throw new Error(
        'Output starts with ``` but no matching closing ``` found'
      )
    }
  }

  jsStr = sanitizeBadJsObject(jsStr)

  let parsed: unknown
  try {
    // Use Function constructor to safely evaluate the object literal
    parsed = Function(`"use strict"; return (${jsStr})`)()
  } catch (err) {
    console.error('Failed to parse LLM JS object output:', err)
    console.error('RAW broken JS object:\n', jsStr.slice(0, 1000))
    throw err
  }

  const { translations, modifiedFiles, namespace } = parsed as ParsedLLMResult

  return {
    translations,
    modifiedFiles,
    namespace,
  }
}
