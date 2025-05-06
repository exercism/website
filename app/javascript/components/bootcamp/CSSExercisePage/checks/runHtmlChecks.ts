import { numTagsUsed } from './html/numTagsUsed'
import { tagOccursNoMoreThan } from './html/tagOccursNoMoreThan'
import { Check, ChecksResult, runChecks } from './runChecks'

const htmlCheckFunctions: Record<string, Function> = {
  tagOccursNoMoreThan,
  numTagsUsed,
}

export function runHtmlChecks(
  checks: Check[],
  htmlValue: string
): ChecksResult {
  return runChecks(checks, htmlValue, htmlCheckFunctions)
}
