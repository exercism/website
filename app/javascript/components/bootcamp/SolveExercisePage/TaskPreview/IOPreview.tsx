import React from 'react'
import { CodeRun } from '../TestResultsView/CodeRun'
import { generateCodeRunString } from '../hooks/useSetupStores'
export function IOPreview({ firstTest }: { firstTest: TaskTest }) {
  return (
    <div className="scenario-lhs">
      <div className="scenario-lhs-content">
        <h3>
          <strong>Scenario: </strong>
          {firstTest.name}
        </h3>
        <table className="io-test-result-info">
          <tbody>
            <CodeRun
              codeRun={generateCodeRunString(
                firstTest.function,
                firstTest.params
              )}
            />
            <tr>
              <th>Expected:</th>
              <td>{firstTest.expected}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  )
}
