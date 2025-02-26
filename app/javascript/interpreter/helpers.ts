import { toSentence } from '@/utils/toSentence'
import { isArray } from './checks'
import {
  BinaryExpression,
  FunctionCallExpression,
  Expression,
  GroupingExpression,
} from './expression'
import { Location } from './location'
import { Statement } from './statement'
import { JikiObject, unwrapJikiObject } from './jikiObjects'

export function formatJikiObject(value?: any): string {
  if (value === undefined) {
    return ''
  }

  if (value instanceof JikiObject) {
    return value.toString()
  }

  return JSON.stringify(value)
}

export function codeTag(code: string | JikiObject, location: Location): string {
  // console.log(code)

  let parsedCode: string
  if (code instanceof JikiObject) {
    parsedCode = code.toString()
  } else {
    parsedCode = code
  }

  const from = location.absolute.begin
  const to = location.absolute.end
  return `<code data-hl-from="${from}" data-hl-to="${to}">${parsedCode}</code>`
}
