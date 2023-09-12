import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../../test-utils'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MentorAgainStep } from '../../../../../../app/javascript/components/mentoring/discussion/finished-wizard/MentorAgainStep'
import { silenceConsole } from '../../../../support/silence-console'
import { TestQueryCache } from '../../../../support/TestQueryCache'
import { awaitPopper } from '../../../../support/await-popper'
import { queryClient } from '../../../../setupTests'

test('disables buttons when choosing to mentor again', async () => {
  const student = {
    handle: 'student',
    links: { block: 'https://exercism.test/block' },
  }

  const server = setupServer(
    rest.delete('https://exercism.test/block', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ student: {} }))
    })
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <MentorAgainStep student={student} onYes={() => null} onNo={() => null} />
    </TestQueryCache>
  )

  const yesBtn = await screen.findByRole('button', { name: 'Yes' })
  const noBtn = await screen.findByRole('button', { name: 'No' })

  userEvent.click(yesBtn)

  await waitFor(() => {
    expect(yesBtn).toBeDisabled()
  })
  await waitFor(() => {
    expect(noBtn).toBeDisabled()
  })

  await awaitPopper()
  server.close()
})

test('shows loading message when choosing to mentor again', async () => {
  const student = {
    handle: 'student',
    links: { block: 'https://exercism.test/block' },
  }
  const server = setupServer(
    rest.delete('https://exercism.test/block', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({ student: {} }))
    })
  )
  server.listen()

  render(
    <MentorAgainStep student={student} onYes={() => null} onNo={() => null} />
  )
  userEvent.click(screen.getByRole('button', { name: 'Yes' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows API errors when choosing to mentor again', async () => {
  silenceConsole()
  const student = {
    handle: 'student',
    links: { block: 'https://exercism.test/block' },
  }
  const server = setupServer(
    rest.delete('https://exercism.test/block', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: { message: 'Unable to update student' },
        })
      )
    })
  )
  server.listen()

  render(
    <MentorAgainStep student={student} onYes={() => null} onNo={() => null} />
  )
  userEvent.click(screen.getByRole('button', { name: 'Yes' }))

  expect(
    await screen.findByText('Unable to update student')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic error when choosing to mentor again', async () => {
  silenceConsole()
  const student = {
    handle: 'student',
    links: { block: 'https://exercism.test/block' },
  }

  render(<MentorAgainStep student={student} />)
  userEvent.click(screen.getByRole('button', { name: 'Yes' }))

  expect(
    await screen.findByText('Unable to update student')
  ).toBeInTheDocument()
})
test('disables buttons when choosing to not mentor again', async () => {
  const student = {
    handle: 'student',
    links: { block: 'https://exercism.test/block' },
  }
  const server = setupServer(
    rest.post('https://exercism.test/block', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({ student: {} }))
    })
  )
  server.listen()

  render(<MentorAgainStep student={student} />)
  const yesButton = screen.getByRole('button', { name: 'Yes' })
  const noButton = screen.getByRole('button', { name: 'No' })
  userEvent.click(noButton)

  await waitFor(() => {
    expect(yesButton).toBeDisabled()
  })
  await waitFor(() => {
    expect(noButton).toBeDisabled()
  })

  server.close()
})

test('shows loading message when choosing to not mentor again', async () => {
  const student = {
    handle: 'student',
    links: { block: 'https://exercism.test/block' },
  }
  const server = setupServer(
    rest.post('https://exercism.test/block', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({ student: {} }))
    })
  )
  server.listen()

  render(<MentorAgainStep student={student} />)
  userEvent.click(screen.getByRole('button', { name: 'No' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows API errors when choosing to not mentor again', async () => {
  silenceConsole()
  const student = {
    handle: 'student',
    links: { block: 'https://exercism.test/block' },
  }
  const server = setupServer(
    rest.post('https://exercism.test/block', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: { message: 'Unable to update student' },
        })
      )
    })
  )
  server.listen()

  render(<MentorAgainStep student={student} />)
  userEvent.click(screen.getByRole('button', { name: 'No' }))

  expect(
    await screen.findByText('Unable to update student')
  ).toBeInTheDocument()

  server.close()
})

test('shows generic error when choosing to not mentor again', async () => {
  silenceConsole()
  const student = {
    handle: 'student',
    links: { block: 'https://exercism.test/block' },
  }

  render(<MentorAgainStep student={student} />)
  userEvent.click(screen.getByRole('button', { name: 'No' }))

  expect(
    await screen.findByText('Unable to update student')
  ).toBeInTheDocument()
})
