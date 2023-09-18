import React from 'react'
import '@testing-library/jest-dom/extend-expect'
import { screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { render } from '../../test-utils'
import { default as MarkdownEditor } from '@/components/common/MarkdownEditor'

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

  const text = await screen.findByText('Unable to parse markdown')
  expect(text).toBeInTheDocument()
})
