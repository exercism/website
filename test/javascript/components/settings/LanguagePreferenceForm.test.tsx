import React from 'react'
import { screen, waitFor } from '@testing-library/react'
import { render } from '../../test-utils'
import userEvent from '@testing-library/user-event'
import { rest } from 'msw'
import { setupServer } from 'msw/node'
import '@testing-library/jest-dom/extend-expect'
import LanguagePreferenceForm from '@/components/settings/LanguagePreferenceForm'

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

const LINKS = { update: 'https://exercism.test/settings/language' }

let body: unknown = null

const server = setupServer(
  rest.patch(LINKS.update, async (req, res, ctx) => {
    body = req.body
    return res(ctx.status(200), ctx.json({}))
  })
)

beforeAll(() => server.listen())
afterAll(() => server.close())

beforeEach(() => {
  body = null
  document.cookie = '_exercism_locale_pref=; path=/; max-age=0'
})

const renderForm = (defaultLocale = 'en') =>
  render(
    <LanguagePreferenceForm
      languages={LANGUAGES}
      comingSoonLanguages={COMING_SOON_LANGUAGES}
      defaultLocale={defaultLocale}
      links={LINKS}
    />
  )

test('renders the current language with its flag', () => {
  renderForm()

  expect(screen.getByRole('heading', { name: 'Language' })).toBeInTheDocument()
  expect(screen.getByText('English')).toBeInTheDocument()
  expect(screen.getByText('(English)')).toBeInTheDocument()
  expect(document.querySelector('.current img.flag')).toHaveAttribute(
    'src',
    '/assets/flags/3x2/gb.svg'
  )
})

test('the current language is the one saved on the account', () => {
  renderForm('hu')

  expect(screen.getByText('magyar')).toBeInTheDocument()
  expect(screen.getByText('(Hungarian)')).toBeInTheDocument()
  expect(document.querySelector('.current img.flag')).toHaveAttribute(
    'src',
    '/assets/flags/3x2/hu.svg'
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

const stubLocation = () => {
  const reload = jest.fn()
  Object.defineProperty(window, 'location', {
    value: { reload },
    writable: true,
  })

  return { reload }
}

// A signed-in user's URLs carry no locale prefix, so the same page re-renders
// in the saved locale.
test('saves and reloads the page', async () => {
  const { reload } = stubLocation()

  renderForm()

  userEvent.click(screen.getByRole('button', { name: 'Change' }))
  userEvent.click(screen.getByText('magyar'))

  await waitFor(() => expect(reload).toHaveBeenCalled())
  expect(body).toEqual({ language: { locale: 'hu' } })
})

test('saves and reloads when switching back to the default locale', async () => {
  const { reload } = stubLocation()

  renderForm('hu')

  userEvent.click(screen.getByRole('button', { name: 'Change' }))
  userEvent.click(screen.getByRole('button', { name: /English/ }))

  await waitFor(() => expect(reload).toHaveBeenCalled())
  expect(body).toEqual({ language: { locale: 'en' } })
})

// The cookie keeps the choice for signed-out pages after signing out.
test('records the locale preference cookie before saving', async () => {
  stubLocation()

  renderForm()

  userEvent.click(screen.getByRole('button', { name: 'Change' }))
  userEvent.click(screen.getByText('magyar'))

  expect(document.cookie).toContain('_exercism_locale_pref=hu')
  await waitFor(() => expect(body).toEqual({ language: { locale: 'hu' } }))
})
