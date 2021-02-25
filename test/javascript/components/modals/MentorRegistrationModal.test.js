import React from 'react'
import { render, screen } from '@testing-library/react'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MentorRegistrationModal } from '../../../../app/javascript/components/modals/MentorRegistrationModal'
import { TestQueryCache } from '../../support/TestQueryCache'

test('preserves chosen tracks when moving through steps', async () => {
  const links = {
    chooseTrackStep: {
      tracks: 'https://exercism.test/tracks',
    },
    commitStep: {},
  }
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(
        ctx.status(200),
        ctx.json({
          tracks: [
            {
              id: 'ruby',
              title: 'Ruby',
              icon_url: 'https://exercism.test/tracks/ruby.png',
              avg_wait_time: '2 days',
              num_solutions_queued: 550,
            },
          ],
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <MentorRegistrationModal open={true} links={links} ariaHideApp={false} />
    </TestQueryCache>
  )

  userEvent.click(await screen.findByRole('checkbox', { name: /Ruby/ }))
  userEvent.click(await screen.findByRole('button', { name: /Continue/ }))
  userEvent.click(await screen.findByRole('button', { name: /Back/ }))

  expect(await screen.findByRole('checkbox', { name: /Ruby/ })).toBeChecked()
})
