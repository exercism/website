import { toSentence } from '@/utils/toSentence'
import { isArray } from './checks'
import {
  BinaryExpression,
  CallExpression,
  Expression,
  GroupingExpression,
} from './expression'
import { Location } from './location'
import { Statement } from './statement'

export function formatLiteral(value?: any): string {
  if (value === undefined) {
    return ''
  }

  return JSON.stringify(value, null, 1).replace(/\n\s*/g, ' ')
}

export function codeTag(code: string, location: Location): string {
  const from = location.absolute.begin
  const to = location.absolute.end
  return `<code data-hl-from="${from}" data-hl-to="${to}">${code}</code>`
}
