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
  return (
    <div className="[&_h5]:font-bold [&_p]:font-mono text-[16px] [&_h5]:uppercase [&_h5]:leading-140  [&_p_span]:rounded-3">
      <CodeRun codeRun={result.codeRun} />
      {firstFailingExpect ? (
        firstFailingExpect.testsType === 'state' ? (
          <StateTestResultView
            descriptionHtml={firstFailingExpect.descriptionHtml!}
          />
        ) : (
          <IOTestResultView diff={firstFailingExpect.diff} />
        )
      ) : null}
    </div>
  )
}
