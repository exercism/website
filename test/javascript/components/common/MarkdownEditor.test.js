import React from 'react'
import { render, waitFor, fireEvent } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MarkdownEditor } from '../../../../app/javascript/components/common/MarkdownEditor'

test('shows error message when API returns an error', async () => {
  const server = setupServer(
    rest.get('https://exercism.test/parse_markdown', (req, res, ctx) => {
      return res(ctx.status(500))
    })
  )
  server.listen()

  const { getByTitle, queryByText } = render(
    <MarkdownEditor
      contextId="test"
      url="https://exercism.test/parse_markdown"
    />
  )
  fireEvent.click(getByTitle('Toggle Preview (Ctrl-P)'))

  await waitFor(() =>
    expect(queryByText('Unable to parse markdown')).toBeInTheDocument()
  )

  server.close()
})
