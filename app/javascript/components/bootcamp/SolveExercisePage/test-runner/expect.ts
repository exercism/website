import { isArray } from '@/interpreter/checks'
import isEqual from 'lodash.isequal'

export function expect({
  actual,
  name,
  slug,
  errorHtml,
  note,
  testsType,
}: {
  actual: any
  name?: string
  slug?: string
  errorHtml?: string
  note?: string
  testsType: TestsType
}): Record<AvailableMatchers, (expected?: any) => MatcherResult> {
  const returnObject: Omit<MatcherResult, 'pass' | 'expected'> = {
    actual,
    slug: slug ?? '',
    name: name ?? '',
    errorHtml,
    note,
    testsType,
  }
  return {
    toBeDefined() {
      return {
        ...returnObject,
        pass: actual !== undefined && actual !== null,
      }
    },
    toBeUndefined() {
      return {
        ...returnObject,
        pass: actual === undefined || actual === null,
      }
    },
    toBe(expected: any) {
      return {
        ...returnObject,
        expected,
        pass: actual === expected,
      }
    },
    toBeTrue() {
      return {
        ...returnObject,
        expected: true,
        pass: actual === true,
      }
    },
    toBeFalse() {
      return {
        ...returnObject,
        expected: false,
        pass: actual === false,
      }
    },
    toEqual(expected: any) {
      return {
        ...returnObject,
        expected,
        pass: isEqual(expected, actual),
      }
    },
    toBeGreaterThanOrEqual(expected: number) {
      return {
        ...returnObject,
        expected,
        pass: actual >= expected,
      }
    },
    toBeLessThanOrEqual(expected: number) {
      return {
        ...returnObject,
        expected,
        pass: actual <= expected,
      }
    },

    toIncludeSameMembers(expected: any[]) {
      let pass
      if (expected == null || actual == null) {
        pass = false
      } else if (!isArray(expected) || !isArray(actual)) {
        pass = false
      } else {
        pass = isEqual([...expected].sort(), [...actual].sort())
      }
      return {
        ...returnObject,
        expected,
        pass,
      }
    },
  }
}
