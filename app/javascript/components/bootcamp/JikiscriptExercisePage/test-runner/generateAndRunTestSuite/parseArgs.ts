import { isString } from '@/interpreter/checks'
import { genericSetupFunctions } from './genericSetupFunctions'

export function parseArgs(args: any[]) {
  return args.map((elem) => {
    if (!isString(elem)) {
      return elem
    }
    if (!(elem.startsWith('setup.') && elem.endsWith(')'))) {
      return elem
    }

    // Wild dark magic
    return new Function('setup', `"use strict"; return (${elem});`)(
      genericSetupFunctions
    )
  })
}
