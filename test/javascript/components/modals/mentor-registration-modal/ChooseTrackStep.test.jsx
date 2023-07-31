import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import '@testing-library/jest-dom/extend-expect'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import { ChooseTrackStep } from '../../../../../app/javascript/components/modals/mentor-registration-modal/ChooseTrackStep'
import userEvent from '@testing-library/user-event'
import { TestQueryCache } from '../../../support/TestQueryCache'
import { silenceConsole } from '../../../support/silence-console'

/* TODO: Remove this when the tests below are readded */
test('placeholder', async () => {})

/* TODO: These tests don't seem to corrolate to the actual class
 * Things like selected and setSelected need to be passed in for
 * these tests to function.
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
              median_wait_time: '2 days',
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
      <ChooseTrackStep
        selected={[]}
        links={{ tracks: 'https://exercism.test/tracks' }}
      />
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

test('shows errors when pulling tracks', async () => {
  silenceConsole()
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Unable to pull tracks',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <ChooseTrackStep
        selected={[]}
        links={{ tracks: 'https://exercism.test/tracks' }}
      />
    </TestQueryCache>
  )

  expect(await screen.findByText('Unable to pull tracks')).toBeInTheDocument()
})

test('shows generic errors when pulling tracks', async () => {
  silenceConsole()

  render(
    <TestQueryCache>
      <ChooseTrackStep selected={[]} links={{ tracks: 'wrong' }} />
    </TestQueryCache>
  )

  expect(await screen.findByText('Unable to fetch tracks')).toBeInTheDocument()
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
              median_wait_time: '2 days',
              num_solutions_queued: 550,
            },
          ],
        })
      )
    })
  )
  server.listen()

  var selected = []
  const setSelected = (s) => {
    selected = s
  }

  render(
    <ChooseTrackStep
      links={{ tracks: 'https://exercism.test/tracks' }}
      selected={selected}
      setSelected={setSelected}
    />
  )

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
              median_wait_time: '2 days',
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
      <ChooseTrackStep
        selected={[]}
        links={{ tracks: 'https://exercism.test/tracks' }}
      />
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
              median_wait_time: '2 days',
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
      <ChooseTrackStep
        selected={[]}
        links={{ tracks: 'https://exercism.test/tracks' }}
      />
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
              median_wait_time: '2 days',
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
      <ChooseTrackStep
        selected={[]}
        links={{ tracks: 'https://exercism.test/tracks' }}
      />
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

test('searches tracks', async () => {
  const tracks = [
    {
      id: 'ruby',
      title: 'Ruby',
      icon_url: 'https://exercism.test/tracks/ruby.png',
      median_wait_time: '2 days',
      num_solutions_queued: 550,
    },
    {
      id: 'go',
      title: 'Go',
      icon_url: 'https://exercism.test/tracks/go.png',
      median_wait_time: '3 days',
      num_solutions_queued: 0,
    },
  ]
  const server = setupServer(
    rest.get('https://exercism.test/tracks', (req, res, ctx) => {
      const criteria = req.url.searchParams.get('criteria')

      const searched = tracks.filter((track) => track.id === criteria)

      return res(ctx.status(200), ctx.json({ tracks: searched }))
    })
  )
  server.listen()

  render(
    <TestQueryCache>
      <ChooseTrackStep
        selected={[]}
        links={{ tracks: 'https://exercism.test/tracks' }}
      />
    </TestQueryCache>
  )
  userEvent.type(screen.getByRole('textbox'), 'go')

  expect(
    await screen.findByRole('checkbox', {
      name: 'Go Avg. wait time ~ 3 days 0 solutions queued',
    })
  ).toBeInTheDocument()
  expect(
    screen.queryByRole('checkbox', {
      name: 'Ruby Avg. wait time ~ 2 days 550 solutions queued',
    })
  ).not.toBeInTheDocument()
})*/
