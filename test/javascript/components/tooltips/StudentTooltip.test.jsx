import React from 'react'
import { render, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { StudentTooltip } from '@/components/tooltips'

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

  const { getByText } = render(
    <StudentTooltip endpoint="https://exercism.test/tooltips/mentored_student/1" />
  )

  await waitFor(() => expect(getByText('mentee')).toBeInTheDocument())

  server.close()
})
