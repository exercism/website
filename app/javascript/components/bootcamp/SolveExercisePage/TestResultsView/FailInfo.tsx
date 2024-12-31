import React from 'react'
import { CodeRun } from './CodeRun'
import { IOTestResultView } from './IOTestResultView'
import { StateTestResultView } from './StateTestResultView'
import type { ProcessedExpect } from './useInspectedTestResultView'

export function FailInfo({
  result,
  firstFailingExpect,
}: {
  result: NewTestResult
  firstFailingExpect: ProcessedExpect | null
}) {
  if (!firstFailingExpect) {
    return null
  }
  if (firstFailingExpect.testsType === 'state') {
    return (
      <>
        <p>
          The first scenario is ... The first scenario is ... The first scenario
          is ... The first scenario is ...
        </p>
        <StateTestResultView
          descriptionHtml={firstFailingExpect.descriptionHtml!}
        />
      </>
    )
  } else {
    return (
      <>
        <table className="io-test-result-info">
          <CodeRun codeRun={result.codeRun} />
          <IOTestResultView diff={firstFailingExpect.diff} />
        </table>
      </>
    )
  }
}
