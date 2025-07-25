export type ParsedLLMResult = {
  translations: Record<string, string>
  modifiedFiles: Record<string, string>
  namespace: string | undefined
}

export function parseLLMOutputHaml(output: string): ParsedLLMResult {
  let jsonStr = output.trim()

  if (jsonStr.startsWith('```')) {
    const match = jsonStr.match(/```(?:json)?\s*([\s\S]+?)\s*```/)
    if (match) {
      jsonStr = match[1].trim()
    } else {
      throw new Error(
        '❌ Output starts with ``` but no matching closing ``` found'
      )
    }
  }

  let parsed: unknown
  try {
    parsed = JSON.parse(jsonStr)
  } catch (err) {
    console.error('❌ Failed to parse LLM JSON output:', err)
    throw err
  }

  const { translations, modifiedFiles, namespace } = parsed as ParsedLLMResult

  return {
    translations,
    modifiedFiles,
    namespace,
  }
}
