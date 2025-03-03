declare type AvailableMatchers =
  | 'toBe'
  | 'toBeTrue'
  | 'toBeFalse'
  | 'toBeDefined'
  | 'toBeUndefined'
  | 'toEqual'
  | 'toBeGreaterThanOrEqual'
  | 'toBeLessThanOrEqual'
  | 'toIncludeSameMembers'

interface MatcherResult {
  actual: any
  pass: boolean
  codeRun?: string
  errorHtml?: string
  expected?: any
  matcher: AvailableMatchers
}
