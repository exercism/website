import React from 'react'
export function StatePreview({
  firstTest,
}: {
  firstTest: TaskTest
  config: Config
}) {
  return (
    <div className="scenario-lhs">
      <div className="scenario-lhs-content">
        <h3>
          <strong>Scenario: </strong>
          {firstTest.name}
        </h3>
      </div>
    </div>
  )
}
