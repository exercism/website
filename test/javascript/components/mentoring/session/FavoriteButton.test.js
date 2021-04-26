import React from 'react'
import {
  render,
  screen,
  waitForElementToBeRemoved,
} from '@testing-library/react'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { FavoriteButton } from '../../../../../app/javascript/components/mentoring/session/FavoriteButton'
import userEvent from '@testing-library/user-event'
import { silenceConsole } from '../../../support/silence-console'

test('mark student as a favorite', async () => {
  const server = setupServer(
    rest.post('https://exercism.test/favorites', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  const student = {
    isFavorite: false,
    links: { favourite: 'https://exercism.test/favorites' },
  }
  render(<FavoriteButton student={student} onSuccess={() => {}} />)
  userEvent.click(screen.getByRole('button', { name: 'Add to favorites' }))
  await waitForElementToBeRemoved(screen.getByText('Loading'))

  expect(screen.getByText('Favorited')).toBeInTheDocument()

  server.close()
})

test('mark student as a favorite returns an API error', async () => {
  silenceConsole()
  const server = setupServer(
    rest.post('https://exercism.test/favorites', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Student does not exist',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <FavoriteButton
      isFavorite={false}
      endpoint="https://exercism.test/favorites"
    />
  )
  userEvent.click(screen.getByRole('button', { name: 'Add to favorites' }))
  await waitForElementToBeRemoved(screen.getByText('Loading'))

  expect(screen.getByText('Student does not exist')).toBeInTheDocument()
  expect(
    await screen.findByRole('button', { name: 'Add to favorites' })
  ).toBeInTheDocument()

  server.close()
})

test('mark student as a favorite fails unexpectedly', async () => {
  silenceConsole()

  render(<FavoriteButton isFavorite={false} endpoint="weirdendpoint" />)
  userEvent.click(screen.getByRole('button', { name: 'Add to favorites' }))
  await waitForElementToBeRemoved(screen.getByText('Loading'))

  expect(
    screen.getByText('Unable to mark student as a favorite')
  ).toBeInTheDocument()
  expect(
    await screen.findByRole('button', { name: 'Add to favorites' })
  ).toBeInTheDocument()
})

test('unfavorite a student', async () => {
  const server = setupServer(
    rest.delete('https://exercism.test/favorites', (req, res, ctx) => {
      return res(ctx.status(200), ctx.json({}))
    })
  )
  server.listen()

  render(
    <FavoriteButton
      isFavorite={true}
      endpoint="https://exercism.test/favorites"
    />
  )
  userEvent.hover(screen.getByText('Favorited'))
  userEvent.click(await screen.findByRole('button', { name: 'Unfavorite?' }))
  await waitForElementToBeRemoved(screen.getByText('Loading'))

  expect(
    screen.getByRole('button', { name: 'Add to favorites' })
  ).toBeInTheDocument()

  server.close()
})

test('unfavorite a student returns an API error', async () => {
  silenceConsole()
  const server = setupServer(
    rest.delete('https://exercism.test/favorites', (req, res, ctx) => {
      return res(
        ctx.status(422),
        ctx.json({
          error: {
            message: 'Student does not exist',
          },
        })
      )
    })
  )
  server.listen()

  render(
    <FavoriteButton
      isFavorite={true}
      endpoint="https://exercism.test/favorites"
    />
  )
  userEvent.hover(screen.getByText('Favorited'))
  userEvent.click(await screen.findByRole('button', { name: 'Unfavorite?' }))
  await waitForElementToBeRemoved(screen.getByText('Loading'))

  expect(screen.getByText('Student does not exist')).toBeInTheDocument()
  expect(await screen.findByText('Favorited')).toBeInTheDocument()

  server.close()
})

test('unfavorites a student fails unexpectedly', async () => {
  silenceConsole()

  const student = {
    isFavorite: true,
    links: { favourite: 'wrongsite' },
  }
  render(<FavoriteButton student={student} onSuccess={() => {}} />)
  userEvent.hover(screen.getByText('Favorited'))
  userEvent.click(await screen.findByRole('button', { name: 'Unfavorite?' }))
  await waitForElementToBeRemoved(screen.getByText('Loading'))

  expect(
    screen.getByText('Unable to remove student as a favorite')
  ).toBeInTheDocument()
  expect(await screen.findByText('Favorited')).toBeInTheDocument()
})
