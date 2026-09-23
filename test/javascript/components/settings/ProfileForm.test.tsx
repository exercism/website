import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import ProfileForm from '@/components/settings/ProfileForm'

const LINKS = { update: 'https://exercism.test/settings' }

const DEFAULT_USER = {
  name: 'Jane',
  location: 'Paris',
  bio: '',
  seniority: 'junior' as const,
}

const renderForm = () =>
  render(
    <ProfileForm
      defaultUser={DEFAULT_USER}
      defaultProfile={null}
      links={LINKS}
    />
  )

test('renders the profile fields', () => {
  renderForm()

  expect(screen.getByLabelText('Name')).toHaveValue('Jane')
  expect(screen.getByLabelText('Location')).toHaveValue('Paris')
})

test('no longer renders the language picker', () => {
  renderForm()

  expect(
    screen.queryByRole('button', { name: 'Change' })
  ).not.toBeInTheDocument()
  expect(document.querySelector('.c-language-field')).toBeNull()
})
