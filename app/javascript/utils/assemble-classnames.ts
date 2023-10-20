export function assembleClassNames(
  ...args: (string | boolean | null | undefined)[]
): string {
  const classNames = new Set<string>()

  for (const arg of args) {
    // skip falsy, non-string values
    if (!arg || typeof arg !== 'string') continue

    const trimmedArg = arg.trim()

    // skip only whitespace strings
    if (/^\s*$/.test(trimmedArg)) continue

    classNames.add(trimmedArg)
  }

  return [...classNames].join(' ')
}
