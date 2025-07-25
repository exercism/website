export type ParsedLLMResult = {
  translations: Record<string, string>
  modifiedFiles: Record<string, string>
  namespace: string | undefined
}

export function parseLLMOutputHaml(output: string): ParsedLLMResult {
  let jsonStr: string | null = null

  const fencedMatch = output.match(/```json\s*([\s\S]+?)\s*```/i)
  if (fencedMatch) {
    jsonStr = fencedMatch[1].trim()
  } else {
    jsonStr = output.trim()
  }

  let parsed: unknown
  try {
    parsed = JSON.parse(jsonStr)
  } catch (err) {
    console.error('❌ Failed to parse LLM JSON output:', err)
    throw err
  }

  if (
    typeof parsed !== 'object' ||
    !parsed ||
    !('translations' in parsed) ||
    !('modifiedFiles' in parsed)
  ) {
    throw new Error('Invalid LLM output shape')
  }

  const { translations, modifiedFiles, namespace } = parsed as {
    translations: Record<string, string>
    modifiedFiles: Record<string, string>
    namespace?: string
  }

  return {
    translations,
    modifiedFiles,
    namespace,
  }
}
