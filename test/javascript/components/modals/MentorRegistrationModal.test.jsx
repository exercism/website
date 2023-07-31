import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../test-utils'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { MentorRegistrationModal } from '../../../../app/javascript/components/modals/MentorRegistrationModal'

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
        ctx.delay(10),
        ctx.status(200),
        ctx.json({
          tracks: [
            {
              slug: 'ruby',
              title: 'Ruby',
              icon_url: 'https://exercism.test/tracks/ruby.png',
              median_wait_time: 1000,
              num_solutions_queued: 550,
            },
          ],
        })
      )
    })
  )
  server.listen()

  render(
    <MentorRegistrationModal open={true} links={links} ariaHideApp={false} />
  )

  userEvent.click(await screen.findByRole('checkbox', { name: /Ruby/ }))
  userEvent.click(await screen.findByRole('button', { name: /Continue/ }))
  userEvent.click(await screen.findByRole('button', { name: /Back/ }))

  expect(await screen.findByRole('checkbox', { name: /Ruby/ })).toBeChecked()

  server.close()
})
