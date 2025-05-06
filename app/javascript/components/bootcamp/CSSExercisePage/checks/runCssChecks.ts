import {
  elementHasProperty,
  elementHasPropertyValue,
} from './css/elementHasProperty'
import { onlyPropertyGroupsUsed } from './css/onlyPropertyGroupsUsed'
import { onlyPropertiesUsed } from './css/onlyPropertiesUsed'
import { Check, ChecksResult, runChecks } from './runChecks'

const cssCheckFunctions: Record<string, Function> = {
  elementHasProperty,
  elementHasPropertyValue,
  onlyPropertyGroupsUsed,
  onlyPropertiesUsed,
}

export async function runCssChecks(
  checks: Check[],
  cssValue: string
): Promise<ChecksResult> {
  return await runChecks(checks, cssValue, cssCheckFunctions)
}
