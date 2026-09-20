import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../test-utils'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import ProfileForm from '@/components/settings/ProfileForm'

const LANGUAGES = [
  { code: 'en', native: 'English', english: 'English' },
  { code: 'hu', native: 'magyar', english: 'Hungarian' },
]

const LINKS = {
  update: 'https://exercism.test/settings',
  updateLanguage: 'https://exercism.test/settings/language',
}

const DEFAULT_USER = {
  name: 'Jane',
  location: 'Paris',
  bio: '',
  seniority: 'junior' as const,
}

let body: unknown = null

const server = setupServer(
  rest.patch(LINKS.updateLanguage, async (req, res, ctx) => {
    body = req.body
    return res(ctx.status(200), ctx.json({}))
  })
)

beforeAll(() => server.listen())
afterAll(() => server.close())

beforeEach(() => {
  body = null
})

const renderForm = () =>
  render(
    <ProfileForm
      defaultUser={DEFAULT_USER}
      defaultProfile={null}
      languages={LANGUAGES}
      defaultLocale="en"
      links={LINKS}
    />
  )

test('renders the language field alongside name and location', () => {
  renderForm()

  expect(screen.getByText('Language')).toBeInTheDocument()
  expect(screen.getByText('English')).toBeInTheDocument()
  expect(screen.getByText('(English)')).toBeInTheDocument()
})

test('renders an option for each language', () => {
  renderForm()

  userEvent.click(screen.getByRole('button', { name: /English/ }))

  expect(screen.getByText('magyar')).toBeInTheDocument()
  expect(screen.getByText('(Hungarian)')).toBeInTheDocument()
})

test('saves and reloads when a language is selected', async () => {
  const reload = jest.fn()
  Object.defineProperty(window, 'location', {
    value: { reload },
    writable: true,
  })

  renderForm()

  userEvent.click(screen.getByRole('button', { name: /English/ }))
  userEvent.click(screen.getByText('magyar'))

  await waitFor(() => expect(reload).toHaveBeenCalled())
  expect(body).toEqual({ language: { locale: 'hu' } })
})
