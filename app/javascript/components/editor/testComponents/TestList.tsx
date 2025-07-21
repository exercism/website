import React from 'react'
import { Test } from '../types'

export function TestsList({ tests }: { tests: Test[] }) {
  return (
    <div>
      {tests.map((test: Test) => (
        <p key={test.name}>
          name: {test.name}, status: {test.status}, output: {test.output}
        </p>
      ))}
    </div>
  )
}
