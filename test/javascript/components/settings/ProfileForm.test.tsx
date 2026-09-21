import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../test-utils'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import ProfileForm from '@/components/settings/ProfileForm'

const LANGUAGES = [
  {
    code: 'en',
    native: 'English',
    english: 'English',
    flagUrl: '/assets/flags/3x2/gb.svg',
  },
  {
    code: 'hu',
    native: 'magyar',
    english: 'Hungarian',
    flagUrl: '/assets/flags/3x2/hu.svg',
  },
]

const COMING_SOON_LANGUAGES = [
  {
    code: 'fr',
    native: 'français',
    english: 'French',
    flagUrl: '/assets/flags/3x2/fr.svg',
  },
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
      comingSoonLanguages={COMING_SOON_LANGUAGES}
      defaultLocale="en"
      links={LINKS}
    />
  )

test('renders the current language with its flag', () => {
  renderForm()

  expect(screen.getByText('Language')).toBeInTheDocument()
  expect(screen.getByText('English')).toBeInTheDocument()
  expect(screen.getByText('(English)')).toBeInTheDocument()
  expect(document.querySelector('.current img.flag')).toHaveAttribute(
    'src',
    '/assets/flags/3x2/gb.svg'
  )
})

test('renders an option for each language, and the ones coming soon', () => {
  renderForm()

  userEvent.click(screen.getByRole('button', { name: 'Change' }))

  expect(screen.getByText('magyar')).toBeInTheDocument()
  expect(screen.getByText('Hungarian')).toBeInTheDocument()
  expect(screen.getByText('français')).toBeInTheDocument()
  expect(screen.getByText('Coming soon')).toBeInTheDocument()
  expect(document.querySelectorAll('.option img.flag')).toHaveLength(3)
})

test('filters the list as you search', () => {
  renderForm()

  userEvent.click(screen.getByRole('button', { name: 'Change' }))
  userEvent.type(screen.getByLabelText('Search languages'), 'hun')

  expect(screen.getByText('magyar')).toBeInTheDocument()
  expect(screen.queryByText('français')).not.toBeInTheDocument()
})

test('saves and reloads when a language is selected', async () => {
  const reload = jest.fn()
  Object.defineProperty(window, 'location', {
    value: { reload },
    writable: true,
  })

  renderForm()

  userEvent.click(screen.getByRole('button', { name: 'Change' }))
  userEvent.click(screen.getByText('magyar'))

  await waitFor(() => expect(reload).toHaveBeenCalled())
  expect(body).toEqual({ language: { locale: 'hu' } })
})
