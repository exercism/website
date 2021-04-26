import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import '@testing-library/jest-dom/extend-expect'
import { ReportStep } from '../../../../../../app/javascript/components/modals/student/finish-mentor-discussion-modal/ReportStep'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { TestQueryCache } from '../../../../support/TestQueryCache'
import { silenceConsole } from '../../../../support/silence-console'

test('textarea is shown when Report is checked', async () => {
  const discussion = {
    mentor: {},
    links: {
      finish: '',
    },
  }

  render(
    <ReportStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )
  userEvent.click(screen.getByLabelText('Report this discussion to an admin'))

  expect(await screen.findByLabelText('What went wrong?')).toBeInTheDocument()
})

test('textarea is hidden when Report is not checked', async () => {
  const discussion = {
    mentor: {},
    links: {
      finish: '',
    },
  }

  render(
    <ReportStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )

  expect(screen.queryByLabelText('What went wrong?')).not.toBeInTheDocument()
})

test('requeue is checked by default', async () => {
  const discussion = {
    mentor: {},
    links: {
      finish: '',
    },
  }

  render(
    <ReportStep
      onSubmit={jest.fn()}
      onBack={jest.fn()}
      discussion={discussion}
    />
  )

  expect(
    screen.getByLabelText('Put your solution back in the queue for mentoring')
  ).toBeChecked()
})

test('disables buttons while loading', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({}))
    })
  )
  const discussion = {
    mentor: {},
    links: {
      finish: 'https://exercism.test/mentor_ratings',
    },
  }
  server.listen()

  render(
    <TestQueryCache>
      <ReportStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    </TestQueryCache>
  )
  const submitButton = screen.getByRole('button', { name: 'Finish' })
  const backButton = screen.getByRole('button', { name: 'Back' })
  userEvent.click(submitButton)

  await waitFor(() => {
    expect(submitButton).toBeDisabled()
  })
  await waitFor(() => {
    expect(backButton).toBeDisabled()
  })

  server.close()
})

test('shows loading message', async () => {
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({}))
    })
  )
  const discussion = {
    mentor: {},
    links: {
      finish: 'https://exercism.test/mentor_ratings',
    },
  }
  server.listen()

  render(
    <TestQueryCache>
      <ReportStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Finish' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  server.close()
})

test('shows error message', async () => {
  silenceConsole()
  const discussion = {
    mentor: {},
    links: {
      finish: 'https://exercism.test/mentor_ratings',
    },
  }
  const server = setupServer(
    rest.patch('https://exercism.test/mentor_ratings', (req, res, ctx) => {
      return res(
        ctx.delay(10),
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unknown error',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <ReportStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Finish' }))

  expect(await screen.findByText('Unknown error')).toBeInTheDocument()

  server.close()
})

test('shows generic error message', async () => {
  silenceConsole()
  const discussion = {
    mentor: {},
    links: { finish: 'weirdendpoint' },
  }

  render(
    <TestQueryCache>
      <ReportStep
        onSubmit={jest.fn()}
        onBack={jest.fn()}
        discussion={discussion}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('button', { name: 'Finish' }))

  expect(
    await screen.findByText('Unable to submit mentor rating')
  ).toBeInTheDocument()
})
