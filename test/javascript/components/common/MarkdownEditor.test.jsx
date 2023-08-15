import React from 'react'
import { render } from '../../test-utils'
import { waitFor, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MarkdownEditor } from '@/components/common/'
import userEvent from '@testing-library/user-event'

const server = setupServer(
  rest.post('https://exercism.test/parse_markdown', (req, res, ctx) => {
    return res(ctx.status(500))
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('shows error message when API returns an error', async () => {
  render(
    <MarkdownEditor
      contextId="test"
      url="https://exercism.test/parse_markdown"
    />
  )
  const previewButton = await screen.findByTitle('Toggle Preview (Ctrl-P)')
  userEvent.click(previewButton)

  await waitFor(() =>
    expect(screen.queryByText('Unable to parse markdown')).toBeInTheDocument()
  )
})
