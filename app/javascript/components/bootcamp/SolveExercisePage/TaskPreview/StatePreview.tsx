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
        <p>
          The first scenario is {firstTest.name}. The first scenario is{' '}
          {firstTest.name}. The first scenario is {firstTest.name}. The first
          scenario is {firstTest.name}.
        </p>
      </div>
    </div>
  )
}
