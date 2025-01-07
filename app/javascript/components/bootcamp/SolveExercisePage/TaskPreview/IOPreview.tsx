import React from 'react'
import { CodeRun } from '../TestResultsView/CodeRun'
import { generateCodeRunString } from '../hooks/useSetupStores'
export function IOPreview({
  inspectedPreviewTaskTest,
}: {
  inspectedPreviewTaskTest: TaskTest
}) {
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
                inspectedPreviewTaskTest.params
              )}
            />
            <tr>
              <th>Expected:</th>
              <td>{inspectedPreviewTaskTest.expected}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  )
}
