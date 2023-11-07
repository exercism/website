import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestsGroup } from '../../../../app/javascript/components/editor/TestsGroup'

test('hides group if no tests', async () => {
  render(
    <TestsGroup tests={[]}>
      <TestsGroup.Header>No tests</TestsGroup.Header>
    </TestsGroup>
  )

  expect(screen.queryByText('No tests')).not.toBeInTheDocument()
})
