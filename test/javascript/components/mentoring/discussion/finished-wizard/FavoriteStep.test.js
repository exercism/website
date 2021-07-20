import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../../../test-utils'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import { FavoriteStep } from '../../../../../../app/javascript/components/mentoring/discussion/finished-wizard/FavoriteStep'
import { expectConsoleError } from '../../../../support/silence-console'

const server = setupServer(
  rest.post('https://exercism.test/favorite', (req, res, ctx) => {
    return res(ctx.status(200), ctx.json({ student: {} }))
  })
)

beforeAll(() => server.listen())
beforeEach(() => server.resetHandlers())
afterAll(() => server.close())

test('disables buttons when choosing to favorite', async () => {
  const student = {
    handle: 'student',
    links: { favorite: 'https://exercism.test/favorite' },
  }
  const handleFavorite = jest.fn()

  render(<FavoriteStep student={student} onFavorite={handleFavorite} />)

  const favoriteButton = await screen.findByRole('button', {
    name: 'Add to favorites',
  })
  const skipButton = await screen.findByRole('button', { name: 'Skip' })
  userEvent.click(favoriteButton)

  await waitFor(() => {
    expect(favoriteButton).toBeDisabled()
  })
  await waitFor(() => {
    expect(skipButton).toBeDisabled()
  })

  await waitFor(() => expect(handleFavorite).toHaveBeenCalled())
})

test('shows loading message when choosing to favorite', async () => {
  const student = {
    handle: 'student',
    links: { favorite: 'https://exercism.test/favorite' },
  }
  const handleFavorite = jest.fn()

  render(<FavoriteStep student={student} onFavorite={handleFavorite} />)

  userEvent.click(screen.getByRole('button', { name: 'Add to favorites' }))

  expect(await screen.findByText('Loading')).toBeInTheDocument()

  await waitFor(() => expect(handleFavorite).toHaveBeenCalled())
})

test('shows API errors when choosing to favorite', async () => {
  await expectConsoleError(async () => {
    const student = {
      handle: 'student',
      links: { favorite: 'https://exercism.test/favorite' },
    }
    server.use(
      rest.post('https://exercism.test/favorite', (req, res, ctx) => {
        return res(
          ctx.status(200),
          ctx.json({
            error: { message: 'Unable to mark student as a favorite' },
          })
        )
      })
    )

    render(<FavoriteStep student={student} />)
    userEvent.click(screen.getByRole('button', { name: 'Add to favorites' }))

    expect(
      await screen.findByText('Unable to mark student as a favorite')
    ).toBeInTheDocument()
  })
})

test('shows generic error when choosing to mentor again', async () => {
  await expectConsoleError(async () => {
    const student = { handle: 'student', links: { favorite: 'wrongendpoint' } }

    render(<FavoriteStep student={student} />)
    userEvent.click(screen.getByRole('button', { name: 'Add to favorites' }))

    expect(
      await screen.findByText('Unable to mark student as a favorite')
    ).toBeInTheDocument()
  })
})
