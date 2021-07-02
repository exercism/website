import React from 'react'
import { render, waitFor, fireEvent, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MarkdownEditor } from '../../../../app/javascript/components/common/MarkdownEditor'
import userEvent from '@testing-library/user-event'

test('shows error message when API returns an error', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/parse_markdown', (req, res, ctx) => {
      return res(ctx.status(500))
    })
  )
  server.listen()

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

  server.close()
})
