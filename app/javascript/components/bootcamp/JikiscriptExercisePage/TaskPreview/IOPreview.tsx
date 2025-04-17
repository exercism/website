import React from 'react'
import { CodeRun } from '../TestResultsView/CodeRun'
import { generateCodeRunString } from '../utils/generateCodeRunString'
import { formatJikiObject } from '@/interpreter/helpers'
export function IOPreview({
  inspectedPreviewTaskTest,
}: {
  inspectedPreviewTaskTest: TaskTest
}) {
  const expected = inspectedPreviewTaskTest.checks?.[0].value
  return (
    <div className="scenario-lhs">
      <div className="scenario-lhs-content">
        <h3>
          <strong>Scenario: </strong>
          {inspectedPreviewTaskTest.name}
        </h3>
        <table className="io-test-result-info">
          <tbody>
            <CodeRun
              codeRun={generateCodeRunString(
                inspectedPreviewTaskTest.function,
                inspectedPreviewTaskTest.args || []
              )}
            />
            <tr>
              <th>Expected:</th>
              <td>{formatJikiObject(expected)}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  )
}
