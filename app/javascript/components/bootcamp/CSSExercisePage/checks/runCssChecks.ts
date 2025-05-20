import {
  elementHasProperty,
  elementHasPropertyValue,
} from './css/elementHasProperty'
import { onlyPropertyGroupsUsed } from './css/onlyPropertyGroupsUsed'
import { onlyPropertiesUsed } from './css/onlyPropertiesUsed'
import { illegalPropertiesUsed } from './css/illegalPropertiesUsed'
import { Check, ChecksResult, runChecks } from './runChecks'

const cssCheckFunctions: Record<string, Function> = {
  elementHasProperty,
  elementHasPropertyValue,
  onlyPropertyGroupsUsed,
  onlyPropertiesUsed,
  illegalPropertiesUsed,
}

export async function runCssChecks(
  checks: Check[],
  cssValue: string
): Promise<ChecksResult> {
  return await runChecks(checks, cssValue, cssCheckFunctions)
}
