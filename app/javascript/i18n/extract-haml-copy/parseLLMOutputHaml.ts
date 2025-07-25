export type ParsedLLMResult = {
  translations: Record<string, string>
  modifiedFiles: Record<string, string>
  namespace: string | undefined
}

export function sanitizeBadJsonEscapes(input: string): string {
  return input
    .replace(/^```json\s*/i, '')
    .replace(/^```\s*/i, '')
    .replace(/```$/, '')
    .replace(/\r\n/g, '\n')
    .replace(/\\(?!["\\/bfnrtu])/g, '\\\\')
    .replace(/\\…/g, '…')
    .replace(/[\u0000-\u001F]+/g, '')
    .trim()
}

export function parseLLMOutputHaml(output: string): ParsedLLMResult {
  let jsonStr = output.trim()

  if (jsonStr.startsWith('```')) {
    const match = jsonStr.match(/```(?:json)?\s*([\s\S]+?)\s*```/)
    if (match) {
      jsonStr = match[1].trim()
    } else {
      throw new Error(
        'Output starts with ``` but no matching closing ``` found'
      )
    }
  }

  jsonStr = sanitizeBadJsonEscapes(jsonStr)

  let parsed: unknown
  try {
    parsed = JSON.parse(jsonStr)
  } catch (err) {
    console.error('Failed to parse LLM JSON output:', err)
    console.error('RAW broken JSON:\n', jsonStr.slice(0, 1000))
    throw err
  }

  const { translations, modifiedFiles, namespace } = parsed as ParsedLLMResult

  return {
    translations,
    modifiedFiles,
    namespace,
  }
}
