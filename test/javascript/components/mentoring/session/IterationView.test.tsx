import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationView } from '../../../../../app/javascript/components/mentoring/session/IterationView'
import { Iteration } from '../../../../../app/javascript/components/types'
import { TestQueryCache } from '../../../support/TestQueryCache'
import { createIteration } from '../../../factories/IterationFactory'

test('next iteration button is disabled when on last iteration', async () => {
  const iterations: readonly Iteration[] = [createIteration({})]

  render(
    <TestQueryCache enabled={false}>
      <IterationView
        iterations={iterations}
        currentIteration={iterations[0]}
        language="ruby"
        settings={{ scroll: false, click: false }}
        onClick={jest.fn()}
        indentSize={2}
        isOutOfDate={false}
        setSettings={jest.fn()}
      />
    </TestQueryCache>
  )

  expect(
    screen.queryByRole('button', { name: 'Go to iteration 1' })
  ).not.toBeInTheDocument()
})
