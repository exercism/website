import React from 'react'
import { act, screen, waitFor } from '@testing-library/react'
import { render } from '../../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { CommitStep } from '../../../../../app/javascript/components/modals/mentor-registration-modal/CommitStep'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { expectConsoleError } from '../../../support/silence-console'
import flushPromises from 'flush-promises'
import { awaitPopper } from '../../../support/await-popper'

test('continue button is disabled when not everything is checked', async () => {
  render(<CommitStep links={{}} />)

  userEvent.click(
    screen.getByRole('checkbox', { name: /Abide by the Code of Conduct/ })
  )

  expect(screen.getByRole('button', { name: 'Continue' })).toBeDisabled()
})

test('continue button is enabled when all checkboxes have been checked', async () => {
  render(<CommitStep links={{}} />)

  userEvent.click(
    screen.getByRole('checkbox', { name: /Abide by the Code of Conduct/ })
  )
  userEvent.click(
    screen.getByRole('checkbox', {
      name: /Be patient, empathic and kind to those you're mentoring/,
    })
  )
  userEvent.click(
    screen.getByRole('checkbox', { name: /Demonstrate intellectual humility/ })
  )
  userEvent.click(
    screen.getByRole('checkbox', {
      name: /Not use Exercism to promote personal agendas/,
    })
  )

  expect(
    await screen.findByRole('button', { name: 'Continue' })
  ).not.toBeDisabled()
})

test('continue and back button are disabled while request is sending', async () => {
  const links = {
    registration: 'https://exercism.test/registration',
  }
  const server = setupServer(
    rest.post('https://exercism.test/registration', (req, res, ctx) => {
      return res(ctx.delay(10), ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  render(<CommitStep links={links} onContinue={() => null} />)

  userEvent.click(
    await screen.findByRole('checkbox', {
      name: /Abide by the Code of Conduct/,
    })
  )
  userEvent.click(
    await screen.findByRole('checkbox', {
      name: /Be patient, empathic and kind to those you're mentoring/,
    })
  )
  userEvent.click(
    await screen.findByRole('checkbox', {
      name: /Demonstrate intellectual humility/,
    })
  )
  userEvent.click(
    await screen.findByRole('checkbox', {
      name: /Not use Exercism to promote personal agendas/,
    })
  )
  await act(async () => {
    userEvent.click(await screen.findByRole('button', { name: /Continue/ }))
  })
  await awaitPopper()

  await waitFor(() => {
    expect(screen.getByRole('button', { name: /Continue/ })).toBeDisabled()
    expect(screen.getByRole('button', { name: /Back/ })).toBeDisabled()
  })

  await flushPromises()
  await awaitPopper()
  // queryClient.cancelQueries()
  server.close()
})
test('shows API errors', async () => {
  const links = {
    registration: 'https://exercism.test/registration',
  }
  const server = setupServer(
    rest.post('https://exercism.test/registration', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to register',
          },
        })
      )
    })
  )
  server.listen()

  render(<CommitStep links={links} onContinue={() => null} />)

  userEvent.click(
    screen.getByRole('checkbox', { name: /Abide by the Code of Conduct/ })
  )
  userEvent.click(
    screen.getByRole('checkbox', {
      name: /Be patient, empathic and kind to those you're mentoring/,
    })
  )
  userEvent.click(
    screen.getByRole('checkbox', { name: /Demonstrate intellectual humility/ })
  )
  userEvent.click(
    screen.getByRole('checkbox', {
      name: /Not use Exercism to promote personal agendas/,
    })
  )

  await expectConsoleError(async () => {
    userEvent.click(screen.getByRole('button', { name: /Continue/ }))

    expect(await screen.findByText('Unable to register')).toBeInTheDocument()
  })

  flushPromises()
  server.close()
})

test('shows generic errors', async () => {
  const links = {
    registration: 'wrong',
  }

  render(<CommitStep links={links} onContinue={() => null} />)

  userEvent.click(
    screen.getByRole('checkbox', { name: /Abide by the Code of Conduct/ })
  )
  userEvent.click(
    screen.getByRole('checkbox', {
      name: /Be patient, empathic and kind to those you're mentoring/,
    })
  )
  userEvent.click(
    screen.getByRole('checkbox', { name: /Demonstrate intellectual humility/ })
  )
  userEvent.click(
    screen.getByRole('checkbox', {
      name: /Not use Exercism to promote personal agendas/,
    })
  )

  await expectConsoleError(async () => {
    userEvent.click(await screen.findByRole('button', { name: /Continue/ }))

    expect(
      await screen.findByText('Unable to complete registration')
    ).toBeInTheDocument()
  })
})
