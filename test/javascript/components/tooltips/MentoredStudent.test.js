import React from 'react'
import { render, waitFor } from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MentoredStudent } from '../../../../app/javascript/components/tooltips/MentoredStudent'

test('mentored student data is displayed', async () => {
  const server = setupServer(
    rest.get(
      'https://exercism.test/tooltips/mentored_student/1',
      (req, res, ctx) => {
        return res(
          ctx.json({
            id: 1,
            avatar_url: 'https://robohash.org/exercism',
            handle: 'mentee',
            is_starred: true,
            have_mentored_previously: true,
            status: 'First timer',
            updated_at: '2019-10-29T10:31:29Z',
          })
        )
      }
    )
  )
  server.listen()

  const { getByText } = render(
    <MentoredStudent endpoint="https://exercism.test/tooltips/mentored_student/1" />
  )

  await waitFor(() => expect(getByText('Loading')).toBeInTheDocument())
  await waitFor(() => expect(getByText('mentee')).toBeInTheDocument())

  server.close()
})
