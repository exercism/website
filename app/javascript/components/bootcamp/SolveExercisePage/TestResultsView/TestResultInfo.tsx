import React, { useEffect } from 'react'
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
  if (firstExpect.testsType === 'state') {
    let errorHtml = firstExpect.errorHtml || ''
    errorHtml = errorHtml.replace(/{value}/, firstExpect.actual)

    return <StateTestResultView errorHtml={errorHtml} />
  } else {
    return (
      <>
        <table className="io-test-result-info">
          <tbody>
            <CodeRun codeRun={result.codeRun} />
            <IOTestResultView diff={firstExpect.diff} />
          </tbody>
        </table>
      </>
    )
  }
}
