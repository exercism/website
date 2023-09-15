import React from 'react'
import { render, screen } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { StudentTooltip } from '@/components/tooltips'
import { TestQueryCache } from '../../support/TestQueryCache'
import { queryClient } from '../../setupTests'

test('correct information is displayed', async () => {
  const server = setupServer(
    rest.get(
      'https://exercism.test/tooltips/mentored_student/1',
      (req, res, ctx) => {
        return res(
          ctx.json({
            student: {
              id: 1,
              avatar_url: 'https://robohash.org/exercism',
              handle: 'mentee',
              have_mentored_previously: true,
              is_favorited: true,
              updated_at: '2019-10-29T10:31:29Z',
            },
          })
        )
      }
    )
  )
  server.listen()

  render(
    <TestQueryCache queryClient={queryClient}>
      <StudentTooltip endpoint="https://exercism.test/tooltips/mentored_student/1" />
    </TestQueryCache>
  )

  expect(await screen.findByText('mentee')).toBeInTheDocument()

  server.close()
})
