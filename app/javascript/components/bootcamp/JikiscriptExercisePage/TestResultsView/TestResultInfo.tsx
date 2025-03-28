import React from 'react'
import { CodeRun } from './CodeRun'
import { IOTestResultView } from './IOTestResultView'
import { StateTestResultView } from './StateTestResultView'
import type { ProcessedExpect } from './useInspectedTestResultView'

export function TestResultInfo({
  result,
  firstExpect,
}: {
  result: NewTestResult
  firstExpect: ProcessedExpect | null
}) {
  if (!firstExpect) {
    return null
  }
  if (firstExpect.type === 'state') {
    let errorHtml = firstExpect.errorHtml || ''
    errorHtml = errorHtml.replace(/{value}/, firstExpect.actual)

    return (
      <StateTestResultView isPassing={firstExpect.pass} errorHtml={errorHtml} />
    )
  } else {
    return (
      <table className="io-test-result-info">
        <tbody>
          <>
            <CodeRun codeRun={firstExpect.codeRun || result.codeRun} />
            <IOTestResultView diff={firstExpect.diff} />
          </>
        </tbody>
      </table>
    )
  }
}
