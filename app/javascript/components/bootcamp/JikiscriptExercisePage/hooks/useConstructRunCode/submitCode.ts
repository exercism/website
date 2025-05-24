export async function submitCode({
  code,
  testResults,
  postUrl,
  readonlyRanges,
  customFunctions,
}: {
  code: string
  testResults: {
    status: string
    tests: { slug: string; status: string; bonus?: boolean }[]
  }
  postUrl: string
  readonlyRanges:
    | ReadonlyRange[]
    | { html: ReadonlyRange[]; css: ReadonlyRange[] }
    | { html: ReadonlyRange[]; css: ReadonlyRange[]; js: ReadonlyRange[] }
  customFunctions: string[]
}) {
  const response = await fetch(postUrl, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({
      submission: {
        code,
        test_results: testResults,
        readonly_ranges: readonlyRanges,
        custom_functions: customFunctions,
      },
    }),
  })

  if (!response.ok) {
    throw new Error('Failed to submit code')
  }

  return response.json()
}
