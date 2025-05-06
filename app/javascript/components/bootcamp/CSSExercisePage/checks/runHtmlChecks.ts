import { numTagsUsed } from './html/numTagsUsed'
import { tagOccursNoMoreThan } from './html/tagOccursNoMoreThan'
import { Check, ChecksResult, runChecks } from './runChecks'

const htmlCheckFunctions: Record<string, Function> = {
  tagOccursNoMoreThan,
  numTagsUsed,
}

export async function runHtmlChecks(
  checks: Check[],
  htmlValue: string
): Promise<ChecksResult> {
  return await runChecks(checks, htmlValue, htmlCheckFunctions)
}
