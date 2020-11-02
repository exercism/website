import React from 'react'
import { render } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { TestRunSummary } from '../../../../../app/javascript/components/student/editor/TestRunSummary'
import { TestRunStatus } from '../../../../../app/javascript/components/student/Editor'

test('hides cancel button if test run has resolved', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/test_run', (req, res, ctx) => {
      return res(
        ctx.json({
          test_run: {
            id: null,
            submission_uuid: '123',
            status: 'queued',
            message: '',
            tests: [],
          },
        })
      )
    })
  )
  server.listen()
  const { queryByText } = render(
    <TestRunSummary
      submission={{
        id: 2,
        uuid: '123',
        tests_status: 'pass',
        links: {
          cancel: 'https://exercism.test/cancel',
          testRun: 'https://exercism.test/test_run',
        },
      }}
      onUpdate={() => {}}
    />
  )

  expect(queryByText('Cancel')).not.toBeInTheDocument()

  server.close()
})
