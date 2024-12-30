declare type AvailableMatchers =
  | 'toBe'
  | 'toExist'
  | 'toEqual'
  | 'toBeGreaterThanOrEqual'
  | 'toBeLessThanOrEqual'

interface MatcherResult {
  testsType: TestsType
  actual: any
  name: string
  slug: string
  pass: boolean
  descriptionHtml?: string
  note?: string
  expected?: any
}
