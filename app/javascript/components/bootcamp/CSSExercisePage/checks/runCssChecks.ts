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

export async function runCssChecks(
  checks: Check[],
  cssValue: string
): Promise<ChecksResult> {
  return await runChecks(checks, cssValue, cssCheckFunctions)
}
