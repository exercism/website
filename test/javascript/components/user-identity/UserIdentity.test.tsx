import React from 'react'
import { render, screen, waitFor } from '@testing-library/react'
import { UserReputation } from '@/components/user-identity/UserReputation'
import { UserProfileLink } from '@/components/user-identity/UserProfileLink'
import { userIdentityUrl } from '@/components/user-identity/useUserIdentity'

const PAYLOAD = {
  handle: 'iHiD',
  avatar_url: 'https://exercism.test/avatar',
  flair: 'insider',
  has_profile: true,
  reputation: {
    total: '12.4k',
    tracks: { ruby: 840, 'c-sharp': 12 },
  },
}

function mockFetch() {
  const fetchMock = jest.fn().mockResolvedValue({
    ok: true,
    json: async () => PAYLOAD,
  })
  global.fetch = fetchMock as never
  return fetchMock
}

beforeEach(() => {
  document.head.innerHTML = ''
})

test('renders the total reputation', async () => {
  mockFetch()

  render(<UserReputation handle="iHiD" />)

  await waitFor(() => expect(screen.getByText('12.4k')).toBeInTheDocument())
})

test('renders track-scoped reputation, with slugs left un-camelized', async () => {
  mockFetch()

  render(<UserReputation handle="iHiD" track="c-sharp" plain />)

  await waitFor(() => expect(screen.getByText('12')).toBeInTheDocument())
})

test('links to the profile when the user has one', async () => {
  mockFetch()

  render(<UserProfileLink handle="iHiD" text="iHiD's solution" />)

  await waitFor(() =>
    expect(
      screen.getByRole('link', { name: "iHiD's solution" })
    ).toHaveAttribute('href', '/profiles/iHiD')
  )
})

describe('cache busting', () => {
  test('uses a clean url for other users', () => {
    expect(userIdentityUrl('someone-else')).toEqual(
      '/api/v2/users/someone-else'
    )
  })

  test('busts the cache at minute granularity for the current user', () => {
    const meta = document.createElement('meta')
    meta.name = 'user-handle'
    meta.content = 'iHiD'
    document.head.appendChild(meta)

    expect(userIdentityUrl('iHiD')).toEqual(
      `/api/v2/users/iHiD?t=${Math.floor(Date.now() / 60000)}`
    )
  })
})
