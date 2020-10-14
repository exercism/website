import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../../app/javascript/components/common/Editor'

const server = setupServer(
  rest.post('https://exercism.test/submissions', (req, res, ctx) => {
    return res(
      ctx.json({ id: 2, tests_status: 'pending', test_runs: [], message: '' })
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
