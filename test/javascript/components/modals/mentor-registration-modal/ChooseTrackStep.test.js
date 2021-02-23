import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { ChooseTrackStep } from '../../../../../app/javascript/components/modals/mentor-registration-modal/ChooseTrackStep'

test('pulls track information', async () => {
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

  render(<ChooseTrackStep endpoint="https://exercism.test/tracks" />)

  expect(
    await screen.findByRole('checkbox', {
      name: 'Ruby Avg. wait time ~ 2 days 550 solutions queued',
    })
  ).toBeInTheDocument()
  expect(screen.getByRole('presentation')).toHaveAttribute(
    'src',
    'https://exercism.test/tracks/ruby.png'
  )
})
