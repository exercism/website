import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestsList } from '../../../../../app/javascript/components/student/Editor/TestsList'
import { TestStatus } from '../../../../../app/javascript/components/student/Editor/TestRunSummary'

test('only shows until first failed test', async () => {
  const tests = [
    {
      name: 'first test',
      status: TestStatus.PASS,
    },
    {
      name: 'second test',
      status: TestStatus.FAIL,
    },
    {
      name: 'third test',
      status: TestStatus.FAIL,
    },
  ]

  const { queryByText } = render(<TestsList tests={tests} />)

  expect(queryByText('Passed: first test')).toBeInTheDocument()
  expect(queryByText('Failed: second test')).toBeInTheDocument()
  expect(queryByText('Failed: third test')).not.toBeInTheDocument()
})
