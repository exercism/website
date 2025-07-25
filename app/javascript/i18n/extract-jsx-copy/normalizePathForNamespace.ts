export function normalizePathForNamespace(inputPath: string): string {
  // Remove leading ../ and ./ and normalize separators
  const normalized = inputPath.replace(/^\.\.?\//g, '').replace(/\\/g, '/')
  return normalized
}
