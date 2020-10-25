import React from 'react'
import { render, fireEvent, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { Editor } from '../../../../app/javascript/components/student/Editor'

test('clears current submission when resubmitting', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/submissions', (req, res, ctx) => {
      return res(
        ctx.json({
          submission: {
            id: 2,
            tests_status: 'queued',
            test_runs: [],
            message: '',
          },
        })
      )
    })
  )
  server.listen()

  const { getByText, getByLabelText, queryByText } = render(
    <Editor endpoint="https://exercism.test/submissions" />
  )
  fireEvent.change(getByLabelText('Code'), { target: { value: 'Code' } })
  fireEvent.click(getByText('Submit'))
  await waitFor(() => expect(queryByText('Status: queued')).toBeInTheDocument())
  fireEvent.change(getByLabelText('Code'), {
    target: { value: 'Changed code' },
  })
  fireEvent.click(getByText('Submit'))

  await waitFor(() =>
    expect(queryByText('Status: queued')).not.toBeInTheDocument()
  )
  await waitFor(() => expect(queryByText('Status: queued')).toBeInTheDocument())

  server.close()
})

test('shows message when test times out', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/submissions', (req, res, ctx) => {
      return res(
        ctx.json({
          submission: {
            id: 2,
            tests_status: 'queued',
            test_runs: [],
            message: '',
          },
        })
      )
    })
  )
  server.listen()

  const { getByText, getByLabelText, queryByText } = render(
    <Editor endpoint="https://exercism.test/submissions" timeout={0} />
  )
  fireEvent.change(getByLabelText('Code'), { target: { value: 'Code' } })
  fireEvent.click(getByText('Submit'))
  await waitFor(() => expect(queryByText('Status: queued')).toBeInTheDocument())

  await waitFor(() =>
    expect(queryByText('Status: timeout')).toBeInTheDocument()
  )

  server.close()
})

test('does not time out when tests have resolved', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/submissions', (req, res, ctx) => {
      return res(
        ctx.json({
          submission: {
            id: 2,
            tests_status: 'pass',
            test_runs: [],
            message: '',
          },
        })
      )
    })
  )
  server.listen()

  const { getByText, getByLabelText, queryByText } = render(
    <Editor endpoint="https://exercism.test/submissions" timeout={0} />
  )
  fireEvent.change(getByLabelText('Code'), { target: { value: 'Code' } })
  fireEvent.click(getByText('Submit'))
  await waitFor(() => expect(queryByText('Status: pass')).toBeInTheDocument())

  await waitFor(() =>
    expect(queryByText('Status: timeout')).not.toBeInTheDocument()
  )

  server.close()
})

test('cancels a pending submission', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/submissions', (req, res, ctx) => {
      return res(ctx.delay(1000))
    })
  )
  server.listen()

  const { getByText, getByLabelText, queryByText } = render(
    <Editor endpoint="https://exercism.test/submissions" />
  )
  fireEvent.change(getByLabelText('Code'), { target: { value: 'Code' } })
  fireEvent.click(getByText('Submit'))
  fireEvent.click(getByText('Cancel'))

  await waitFor(() =>
    expect(queryByText('Submitting...')).not.toBeInTheDocument()
  )

  server.close()
})
