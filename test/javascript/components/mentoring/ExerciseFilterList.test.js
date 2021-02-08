import React from 'react'
import userEvent from '@testing-library/user-event'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { Queue } from '../../../../app/javascript/components/mentoring/Queue'
import { silenceConsole } from '../../support/silence-console'
import { TestQueryCache } from '../../support/TestQueryCache'

test('shows API errors', async () => {
  silenceConsole()
  const tracks = [
    {
      slug: 'ruby',
      title: 'Ruby',
      links: {
        exercises: 'https://exercism.test/exercises/ruby',
      },
    },
    {
      slug: 'csharp',
      title: 'C#',
      links: {
        exercises: 'https://exercism.test/exercises/csharp',
      },
    },
  ]
  const server = setupServer(
    rest.get('https://exercism.test/exercises', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to fetch exercises',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <Queue
        request={{
          endpoint: 'https://exercism.test/exercises',
          query: { trackSlug: 'ruby' },
        }}
        tracks={tracks}
        sortOptions={[]}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('radio', { name: 'icon for C# track C#' }))

  expect(
    await screen.findByText('Unable to fetch exercises')
  ).toBeInTheDocument()

  server.close()
})
test('shows generic errors', async () => {
  silenceConsole()
  const tracks = [
    {
      slug: 'ruby',
      title: 'Ruby',
      links: {
        exercises: 'weirdendpoint',
      },
    },
    {
      slug: 'csharp',
      title: 'C#',
      links: {
        exercises: 'weirdendpoint',
      },
    },
  ]

  render(
    <TestQueryCache>
      <Queue
        request={{
          endpoint: 'weirdendpoint',
          query: { trackSlug: 'ruby' },
        }}
        tracks={tracks}
        sortOptions={[]}
      />
    </TestQueryCache>
  )
  userEvent.click(screen.getByRole('radio', { name: 'icon for C# track C#' }))

  expect(
    await screen.findByText('Unable to fetch exercises')
  ).toBeInTheDocument()
})
