import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../../app/javascript/components/student/Editor'

const server = setupServer(
  rest.post('https://exercism.test/submissions', (req, res, ctx) => {
    return res(
      ctx.json({
        submission: {
          id: 2,
          tests_status: 'pending',
          test_runs: [],
          message: '',
        },
      })
    )
  }),
  rest.post('https://exercism.test/submissions/pass', (req, res, ctx) => {
    return res(
      ctx.json({
        submission: { id: 2, tests_status: 'pass', test_runs: [], message: '' },
      })
    )
  })
)

beforeAll(() => server.listen())
afterEach(() => server.resetHandlers())
afterAll(() => server.close())

test('clears current submission when resubmitting', async () => {
  const { getByText, queryByText } = render(
    <Editor endpoint="https://exercism.test/submissions" />
  )

  fireEvent.click(getByText('Submit'))
  await waitFor(() =>
    expect(queryByText('Status: pending')).toBeInTheDocument()
  )

  fireEvent.click(getByText('Submit'))
  await waitFor(() =>
    expect(queryByText('Status: pending')).not.toBeInTheDocument()
  )
  await waitFor(() =>
    expect(queryByText('Status: pending')).toBeInTheDocument()
  )
})

test('shows message when test times out', async () => {
  const { getByText, queryByText } = render(
    <Editor endpoint="https://exercism.test/submissions" timeout={0} />
  )

  fireEvent.click(getByText('Submit'))
  await waitFor(() =>
    expect(queryByText('Status: pending')).toBeInTheDocument()
  )
  await waitFor(() =>
    expect(queryByText('Status: timeout')).toBeInTheDocument()
  )
})

test('does not time out when tests have resolved', async () => {
  const { getByText, queryByText } = render(
    <Editor endpoint="https://exercism.test/submissions/pass" timeout={0} />
  )

  fireEvent.click(getByText('Submit'))
  await waitFor(() => expect(queryByText('Status: pass')).toBeInTheDocument())
  await waitFor(() =>
    expect(queryByText('Status: timeout')).not.toBeInTheDocument()
  )
})
