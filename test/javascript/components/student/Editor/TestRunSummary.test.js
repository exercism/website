jest.mock(
  '../../../../../app/javascript/components/student/editor/ExercismMonacoEditor'
)

import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { TestRunSummary } from '../../../../../app/javascript/components/student/editor/TestRunSummary'
import { TestRunStatus } from '../../../../../app/javascript/components/student/editor/types'

test('hides cancel button if test run has resolved', async () => {
  const { queryByText } = render(
    <TestRunSummary
      testRun={{
        id: null,
        submissionUuid: '123',
        status: TestRunStatus.PASS,
        message: '',
        tests: [],
      }}
    />
  )

  expect(queryByText('Cancel')).not.toBeInTheDocument()
})
