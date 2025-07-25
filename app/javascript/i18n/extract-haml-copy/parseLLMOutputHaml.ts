import yaml from 'yaml'

export type ParsedLLMResult = {
  translations: Record<string, string>
  modifiedFiles: Record<string, string>
  namespace: string | undefined
}

export function parseLLMOutputHaml(output: string): ParsedLLMResult {
  const translations: Record<string, string> = {}
  const modifiedFiles: Record<string, string> = {}

  const translationMatch = output.match(
    /```ts\s*export default ({[\s\S]+?})\s*```/
  )
  if (translationMatch) {
    try {
      const parsed = yaml.parse(translationMatch[1])
      Object.assign(translations, parsed)
    } catch (err) {
      console.error('❌ Failed to parse translation block:', err)
      throw err
    }
  }

  const fileBlocks = output.split(/\n+\/\/ === file: (.+?) ===\n/).slice(1)
  for (let i = 0; i < fileBlocks.length; i += 2) {
    const filePath = fileBlocks[i].trim()
    const content = fileBlocks[i + 1]
      .replace(/# end file.*$/, '')
      .replace(/^# i18n-key-prefix:/gm, '-# i18n-key-prefix:')
      .replace(/^# i18n-namespace:/gm, '-# i18n-namespace:')

    modifiedFiles[filePath] = content.trim()
  }

  const sampleNamespace =
    Object.keys(translations)[0]?.split('.')[0] || undefined

  return {
    translations,
    modifiedFiles,
    namespace: sampleNamespace,
  }
}
