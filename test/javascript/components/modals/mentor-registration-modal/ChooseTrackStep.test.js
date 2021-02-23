import React from 'react'
import { render, screen } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { ChooseTrackStep } from '../../../../../app/javascript/components/modals/mentor-registration-modal/ChooseTrackStep'
import userEvent from '@testing-library/user-event'
import { TestQueryCache } from '../../../support/TestQueryCache'

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

  render(
    <TestQueryCache>
      <ChooseTrackStep endpoint="https://exercism.test/tracks" />
    </TestQueryCache>
  )

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

test('selects tracks', async () => {
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

  userEvent.click(
    await screen.findByRole('checkbox', {
      name: 'Ruby Avg. wait time ~ 2 days 550 solutions queued',
    })
  )

  expect(await screen.findByText('1 track selected')).toBeInTheDocument()
  expect(
    await screen.findByRole('checkbox', {
      name: 'Ruby Avg. wait time ~ 2 days 550 solutions queued',
    })
  ).toBeChecked()
})
test('unselects tracks', async () => {
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
      <ChooseTrackStep endpoint="https://exercism.test/tracks" />
    </TestQueryCache>
  )

  userEvent.click(
    await screen.findByRole('checkbox', {
      name: 'Ruby Avg. wait time ~ 2 days 550 solutions queued',
    })
  )
  userEvent.click(
    screen.getByRole('checkbox', {
      name: 'Ruby Avg. wait time ~ 2 days 550 solutions queued',
    })
  )

  expect(await screen.findByText('No tracks selected')).toBeInTheDocument()
  expect(
    await screen.findByRole('checkbox', {
      name: 'Ruby Avg. wait time ~ 2 days 550 solutions queued',
    })
  ).not.toBeChecked()
})
test('continue button is disabled', async () => {
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
      <ChooseTrackStep endpoint="https://exercism.test/tracks" />
    </TestQueryCache>
  )

  expect(screen.getByRole('button', { name: 'Continue' })).toBeDisabled()
})

test('continue button is enabled when a track is checked', async () => {
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
      <ChooseTrackStep endpoint="https://exercism.test/tracks" />
    </TestQueryCache>
  )

  userEvent.click(
    await screen.findByRole('checkbox', {
      name: 'Ruby Avg. wait time ~ 2 days 550 solutions queued',
    })
  )

  expect(
    await screen.findByRole('button', { name: 'Continue' })
  ).not.toBeDisabled()
})
