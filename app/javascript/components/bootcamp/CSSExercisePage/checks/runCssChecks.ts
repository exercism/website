import {
  elementHasProperty,
  elementHasPropertyValue,
} from './css/elementHasProperty'
import { exactPropertiesUsed } from './css/exactPropertiesUsed'
import { onlyPropertiesUsed } from './css/onlyPropertiesUsed'
import { Check, ChecksResult, runChecks } from './runChecks'

const cssCheckFunctions: Record<string, Function> = {
  elementHasProperty,
  elementHasPropertyValue,
  exactPropertiesUsed,
  onlyPropertiesUsed,
}

export function runCssChecks(checks: Check[], cssValue: string): ChecksResult {
  return runChecks(checks, cssValue, cssCheckFunctions)
}
