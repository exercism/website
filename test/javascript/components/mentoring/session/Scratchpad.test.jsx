import React from 'react'
import userEvent from '@testing-library/user-event'
import { render } from '../../../test-utils'
import { screen, waitForElementToBeRemoved, act } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { Scratchpad } from '../../../../../app/javascript/components/mentoring/session/Scratchpad'
import { stubRange } from '../../../support/code-mirror-helpers'
import { build } from '@jackfranklin/test-data-bot'
import { expectConsoleError } from '../../../support/silence-console'

stubRange()

const server = setupServer(
  rest.get('https://exercism.test/scratchpad', (req, res, ctx) => {
    return res(
      ctx.delay(10),
      ctx.json({ scratchpad_page: { content_markdown: '' } })
    )
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

const buildScratchpad = build({
  fields: {
    scratchpad: {
      links: {
        self: 'https://exercism.test/scratchpad',
      },
    },
    exercise: {},
    track: {},
  },
})

test('hides local storage autosave message', async () => {
  const props = buildScratchpad()

  render(<Scratchpad {...props} />)

  await waitForElementToBeRemoved(screen.queryByText('Loading'))
  expect(screen.queryByText(/Autosaved/)).not.toBeInTheDocument()
})

test('shows errors from API', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.patch('https://exercism.test/scratchpad', (req, res, ctx) => {
        return res(
          ctx.status(404),
          ctx.json({
            error: {
              type: 'generic',
              message: 'Unable to save page',
            },
          })
        )
      })
    )
    const props = buildScratchpad()

    render(<Scratchpad {...props} />)
    await waitForElementToBeRemoved(screen.queryByText('Loading'))

    userEvent.click(screen.getByRole('button', { name: 'Save' }))
    expect(await screen.findByText('Unable to save page')).toBeInTheDocument()
  })
})

test('clears errors when resubmitting', async () => {
  await expectConsoleError(async () => {
    server.use(
      rest.patch('https://exercism.test/scratchpad', (req, res, ctx) => {
        return res(
          ctx.status(404),
          ctx.json({
            error: {
              type: 'generic',
              message: 'Unable to save page',
            },
          })
        )
      })
    )
    const props = buildScratchpad()

    render(<Scratchpad {...props} />)

    await waitForElementToBeRemoved(screen.queryByText('Loading'))
    userEvent.click(screen.getByRole('button', { name: 'Save' }))

    expect(await screen.findByText('Unable to save page')).toBeInTheDocument()

    userEvent.click(screen.getByRole('button', { name: 'Save' }))

    expect(screen.queryByText('Unable to save page')).not.toBeInTheDocument()

    await screen.findByText('Unable to save page')
  })
})

test('revert to saved button shows if content changed', async () => {
  const props = buildScratchpad()

  render(<Scratchpad {...props} />)

  await waitForElementToBeRemoved(screen.queryByText('Loading'))

  act(() => {
    document.querySelector('.CodeMirror').CodeMirror.setValue('#Hello')
  })
  expect(
    await screen.findByRole('button', { name: 'Revert to saved' })
  ).toBeInTheDocument()
})

test('revert to saved button is hidden', async () => {
  const props = buildScratchpad()

  render(<Scratchpad {...props} />)

  await waitForElementToBeRemoved(screen.queryByText('Loading'))

  expect(
    screen.queryByRole('button', { name: 'Revert to saved' })
  ).not.toBeInTheDocument()
})
