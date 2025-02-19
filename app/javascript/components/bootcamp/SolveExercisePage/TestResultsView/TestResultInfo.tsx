import React from 'react'
import { CodeRun } from './CodeRun'
import { IOTestResultView } from './IOTestResultView'
import { StateTestResultView } from './StateTestResultView'
import type { ProcessedExpect } from './useInspectedTestResultView'
import { GraphicalIcon } from '@/components/common'

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

    return (
      <StateTestResultView isPassing={firstExpect.pass} errorHtml={errorHtml} />
    )
  } else {
    console.log(firstExpect)
    return (
      <>
        <table className="io-test-result-info">
          <tbody>
            {firstExpect.testsType == 'io/check' ? (
              firstExpect.pass == false &&
              firstExpect.errorHtml && (
                <div className="error-message">
                  <GraphicalIcon icon="bootcamp-cross-red" />
                  <div>
                    <strong>Uh Oh.</strong>{' '}
                    <span
                      dangerouslySetInnerHTML={{
                        __html: firstExpect.errorHtml,
                      }}
                    />
                  </div>
                </div>
              )
            ) : (
              <>
                <CodeRun codeRun={result.codeRun} />
                <IOTestResultView diff={firstExpect.diff} />
              </>
            )}
          </tbody>
        </table>
      </>
    )
  }
}
