import { stringSimilarity } from 'string-similarity-js'
import type { Token } from '../token'
import type { Location } from '../../../location'

export type TypoInfo = {
  actual: string
  potential: string
  location: Location
}

export function isTypo(token: Token): TypoInfo | undefined {
  let intendedType: string | undefined

  if (isTypoOfEquals(token.lexeme)) {
    intendedType = 'equals'
  }

  if (intendedType === undefined) {
    return undefined
  }
  return {
    potential: intendedType,
    actual: token.lexeme,
    location: token.location,
  }
}

export function isTypoOfEquals(word: string): boolean {
  return stringSimilarity(word, 'equals') > 0.8
}
