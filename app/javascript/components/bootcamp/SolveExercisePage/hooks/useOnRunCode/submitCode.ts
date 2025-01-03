export async function submitCode({
  code,
  testResults,
  postUrl,
  readonlyRanges,
}: {
  code: string
  testResults: {
    status: string
    tests: { slug: string; status: string; actual: any }[]
  }
  postUrl: string
  readonlyRanges: { from: number; to: number }[]
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
      },
    }),
  })

  if (!response.ok) {
    throw new Error('Failed to submit code')
  }

  return response.json()
}
