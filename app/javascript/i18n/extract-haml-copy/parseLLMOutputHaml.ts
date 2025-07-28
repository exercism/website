export function parseLLMOutputHaml(output: string): Record<string, string> {
  let jsonStr = output.trim()

  // Remove any code block markers if present
  if (jsonStr.startsWith('```')) {
    const match = jsonStr.match(/```(?:json)?\s*([\s\S]+?)\s*```/)
    if (match) {
      jsonStr = match[1].trim()
    } else {
      // Try to find JSON object even if closing ``` is missing
      jsonStr = jsonStr.replace(/^```(?:json)?\s*/, '').trim()
    }
  }

  // Clean up common LLM output issues
  jsonStr = jsonStr
    .replace(/^(?:json\s*)?{/, '{') // Remove "json" prefix
    .replace(/```$/, '') // Remove trailing ```
    .replace(/\r\n/g, '\n') // Normalize line endings
    .trim()

  try {
    const parsed = JSON.parse(jsonStr)

    // Validate that it's a flat object with string values
    if (
      typeof parsed !== 'object' ||
      parsed === null ||
      Array.isArray(parsed)
    ) {
      throw new Error('Expected a JSON object')
    }

    for (const [key, value] of Object.entries(parsed)) {
      if (typeof key !== 'string' || typeof value !== 'string') {
        throw new Error(`Invalid key-value pair: ${key} -> ${value}`)
      }
    }

    return parsed as Record<string, string>
  } catch (err) {
    console.error('Failed to parse LLM JSON output:', err)
    console.error('RAW output (first 500 chars):\n', jsonStr.slice(0, 500))
    throw new Error(
      `JSON parsing failed: ${
        err instanceof Error ? err.message : 'Unknown error'
      }`
    )
  }
}
