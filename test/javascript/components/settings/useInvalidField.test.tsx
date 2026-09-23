import React from 'react'
import { screen } from '@testing-library/react'
import { render } from '../../test-utils'
import '@testing-library/jest-dom/extend-expect'
import { createMaxLengthAttributes } from '@/components/settings/useInvalidField'
import EmailForm from '@/components/settings/EmailForm'
import HandleForm from '@/components/settings/HandleForm'
import ProfileForm from '@/components/settings/ProfileForm'

const LINKS = { update: 'https://exercism.test/settings' }

test('builds the title from its own namespace', () => {
  const { pattern, title } = createMaxLengthAttributes('Email', 255)

  expect(pattern).toBe('.{0,255}')
  expect(title).toBe('Email must be no longer than 255 characters')
})

test('EmailForm renders the validation title', () => {
  render(<EmailForm defaultEmail="jane@exercism.test" links={LINKS} />)

  expect(screen.getByLabelText('Your email address')).toHaveAttribute(
    'title',
    'Email must be no longer than 255 characters'
  )
})

test('HandleForm renders the validation title', () => {
  render(<HandleForm defaultHandle="jane" links={LINKS} numHandleChanges={0} />)

  expect(screen.getByLabelText('Your handle')).toHaveAttribute(
    'title',
    'Handle must be no longer than 190 characters'
  )
})

test('ProfileForm renders the validation title', () => {
  render(
    <ProfileForm
      defaultUser={{
        name: 'Jane',
        location: 'Paris',
        bio: '',
        seniority: 'junior' as const,
      }}
      defaultProfile={null}
      links={LINKS}
    />
  )

  expect(screen.getByLabelText('Name')).toHaveAttribute(
    'title',
    'Name must be no longer than 255 characters'
  )
})
