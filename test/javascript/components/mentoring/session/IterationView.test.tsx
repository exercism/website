import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { IterationView } from '../../../../../app/javascript/components/mentoring/session/IterationView'
import {
  IterationStatus,
  SubmissionMethod,
  SubmissionTestsStatus,
} from '../../../../../app/javascript/components/types'
import { TestQueryCache } from '../../../support/TestQueryCache'

test('next iteration button is disabled when on last iteration', async () => {
  const iterations = [
    {
      idx: 1,
      uuid: 'uuid',
      status: IterationStatus.TESTING,
      numComments: 0,
      unread: false,
      numEssentialAutomatedComments: 0,
      numActionableAutomatedComments: 0,
      numNonActionableAutomatedComments: 0,
      submissionMethod: SubmissionMethod.CLI,
      createdAt: new Date().toString(),
      testsStatus: SubmissionTestsStatus.QUEUED,
      links: {
        self: '',
        solution: '',
        files: '',
      },
    },
  ]

  render(
    <TestQueryCache enabled={false}>
      <IterationView iterations={iterations} language="ruby" />
    </TestQueryCache>
  )

  expect(
    screen.queryByRole('button', { name: 'Go to iteration 1' })
  ).not.toBeInTheDocument()
})
