export type ParsedLLMResult = {
  translations: Record<string, string>
  modifiedFiles: Record<string, string>
  namespace: string | undefined
}

export function parseLLMOutputHaml(output: string): ParsedLLMResult {
  let parsed: unknown

  try {
    parsed = JSON.parse(output)
  } catch (err) {
    console.error('❌ Failed to parse LLM JSON output:', err)
    throw err
  }

  if (
    typeof parsed !== 'object' ||
    parsed === null ||
    !('translations' in parsed) ||
    !('modifiedFiles' in parsed)
  ) {
    throw new Error(
      '❌ Invalid LLM output format. Expected JSON with translations and modifiedFiles.'
    )
  }

  const { translations, modifiedFiles, namespace } = parsed as {
    translations: Record<string, string>
    modifiedFiles: Record<string, string>
    namespace: string | undefined
  }

  return {
    translations,
    modifiedFiles,
    namespace,
  }
}
