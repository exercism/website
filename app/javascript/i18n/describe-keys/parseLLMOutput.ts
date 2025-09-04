type LLMJson = Record<string, string> | unknown[] // object (your new format) or array (old)
const CODE_FENCE_RE = /^```(?:json)?\s*([\s\S]*?)\s*```$/i

export function parseLLMOutput(raw: string): LLMJson {
  const output = raw.trim()

  // Strip code fences if the model adds them
  const fencedMatch = output.match(CODE_FENCE_RE)
  const unwrapped = fencedMatch ? fencedMatch[1].trim() : output

  // 1) Try direct JSON (object or array)
  try {
    return JSON.parse(unwrapped)
  } catch {
    // 2) Try to salvage by extracting the first top-level JSON object/array
    const firstBrace = unwrapped.indexOf('{')
    const lastBrace = unwrapped.lastIndexOf('}')
    const firstBracket = unwrapped.indexOf('[')
    const lastBracket = unwrapped.lastIndexOf(']')

    const hasObject =
      firstBrace !== -1 && lastBrace !== -1 && lastBrace > firstBrace
    const hasArray =
      firstBracket !== -1 && lastBracket !== -1 && lastBracket > firstBracket

    const candidate = hasObject
      ? unwrapped.slice(firstBrace, lastBrace + 1)
      : hasArray
      ? unwrapped.slice(firstBracket, lastBracket + 1)
      : null

    if (candidate) {
      try {
        return JSON.parse(candidate)
      } catch {
        // fall through to NDJSON attempt
      }
    }

    // 3) As a last resort, attempt NDJSON (one JSON per line)
    const lines = unwrapped
      .split('\n')
      .map((l) => l.trim())
      .filter(Boolean)

    // If it's NDJSON, all lines must be valid JSON
    const parsedLines = lines.map((l) => JSON.parse(l)) // will throw if any line isn't JSON
    return parsedLines
  }
}
