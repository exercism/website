import { Submission, TestRunStatus } from './types'

export const useEditorTestRunStatus = (
  submission: Submission | null
): TestRunStatus | null => {
  return submission?.testRun?.status || null
}
