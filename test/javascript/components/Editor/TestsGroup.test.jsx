import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestsGroup } from '../../../../app/javascript/components/editor/TestsGroup'

test('hides group if no tests', async () => {
  const { queryByText } = render(
    <TestsGroup tests={[]}>
      <TestsGroup.Header>No tests</TestsGroup.Header>
    </TestsGroup>
  )

  expect(queryByText('No tests')).not.toBeInTheDocument()
})
