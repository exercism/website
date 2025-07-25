export type ParsedLLMResult = {
  translations: Record<string, string>
  modifiedFiles: Record<string, string>
  namespace: string | undefined
}

export function parseLLMOutputHaml(output: string): ParsedLLMResult {
  let parsed: unknown

  const cleaned = output
    .trim()
    .replace(/^```json\s*/, '')
    .replace(/```$/, '')

  try {
    parsed = JSON.parse(cleaned)
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
    throw new Error('Invalid parsed structure from LLM')
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
