import React from 'react'
import { render, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { UserSummary } from '../../../../app/javascript/components/tooltips'

test('correct information is displayed', async () => {
  const server = setupServer(
    rest.get(
      'https://exercism.test/tooltips/user_summary/1',
      (req, res, ctx) => {
        return res(
          ctx.json({
            id: 1,
            avatar_url: 'https://robohash.org/exercism',
            name: 'Erik Schierboom',
            handle: 'ErikSchierboom',
            bio:
              'I am a developer with a passion for learning new languages. C# is a well-designed and expressive language that I love programming in.',
            location: 'Arnhem, The Netherlands',
            reputation: {
              total: 300_000,
              tooling: 240_683,
            },
            badges: {
              count: 32,
              latest: ['helpful', 'thumbs-up'],
            },
          })
        )
      }
    )
  )
  server.listen()

  const { getByText } = render(
    <UserSummary endpoint="https://exercism.test/tooltips/user_summary/1" />
  )

  await waitFor(() => expect(getByText('Loading')).toBeInTheDocument())
  await waitFor(() => expect(getByText('Erik Schierboom')).toBeInTheDocument())
  await waitFor(() =>
    expect(getByText('Arnhem, The Netherlands')).toBeInTheDocument()
  )

  server.close()
})
