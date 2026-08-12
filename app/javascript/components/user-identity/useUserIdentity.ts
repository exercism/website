import { QueryClient, useQuery } from '@tanstack/react-query'
import type { Flair } from '@/components/common/HandleWithFlair'

/**
 * User identity data lives at its own CDN-cached endpoint rather than being
 * baked into cached HTML, because it changes independently of every page it
 * appears on. See PERF_DEBUGGING.md.
 */
export type UserIdentity = {
  handle: string
  avatarUrl: string
  flair: Flair | null
  hasProfile: boolean
  reputation: {
    total: string
    tracks: Record<string, number>
  }
}

type UserIdentityPayload = {
  handle: string
  avatar_url: string
  flair: Flair | null
  has_profile: boolean
  reputation: {
    total: string
    tracks: Record<string, number>
  }
}

/**
 * The current user's handle is only ever present on responses that are never
 * CDN-cached (Cloudflare bypasses its cache whenever the _exercism_user_id
 * cookie is set), so reading it here does not make the cached HTML vary.
 */
export function currentUserHandle(): string | null {
  const tag = document.querySelector<HTMLMetaElement>(
    'meta[name="user-handle"]'
  )
  return tag?.content || null
}

/**
 * The endpoint has a one hour TTL and is never purged, so a user would not see
 * their own reputation change for an hour. Rather than shortening the TTL for
 * everyone, we bust the cache for the user's own data at minute granularity.
 *
 * The minute is computed client-side deliberately: deciding it server-side
 * would make the HTML vary by viewer, which is what this whole design avoids.
 * Clock skew is irrelevant as the value only needs to change, not be correct.
 */
function cacheBustParam(handle: string): string {
  if (handle !== currentUserHandle()) return ''

  return `?t=${Math.floor(Date.now() / 60000)}`
}

export function userIdentityUrl(handle: string): string {
  return `/api/v2/users/${encodeURIComponent(handle)}${cacheBustParam(handle)}`
}

let fallbackQueryClient: QueryClient | undefined

/**
 * These components are mounted into many separate React roots, and some of
 * them (e.g. inside the comments list) render outside a provider in tests, so
 * the client is resolved explicitly rather than from context.
 */
function identityQueryClient(): QueryClient {
  if (typeof window !== 'undefined' && window.queryClient) {
    return window.queryClient
  }

  fallbackQueryClient ||= new QueryClient()
  return fallbackQueryClient
}

/**
 * Every component for the same handle shares one request: the query client is
 * a single global, so an identical query key across separately-mounted React
 * roots dedupes into a single fetch.
 */
export function useUserIdentity(handle: string) {
  return useQuery<UserIdentity>(
    {
      queryKey: ['user-identity', handle],
      queryFn: async () => {
        const response = await fetch(userIdentityUrl(handle), {
          // Don't send cookies. The endpoint is anonymous, and sending the
          // session cookie would make Cloudflare bypass its cache for signed-in
          // users, who would otherwise share everyone else's cached copy.
          credentials: 'omit',
          headers: { accept: 'application/json' },
        })
        if (!response.ok) throw response

        const data: UserIdentityPayload = await response.json()

        return {
          handle: data.handle,
          avatarUrl: data.avatar_url,
          flair: data.flair,
          hasProfile: data.has_profile,
          // Track slugs are deliberately not camelized: "c-sharp" must stay
          // "c-sharp" for lookups to work.
          reputation: data.reputation,
        }
      },
      refetchOnWindowFocus: false,
      staleTime: 60 * 60 * 1000,
    },
    identityQueryClient()
  )
}

export function profilePath(handle: string): string {
  return `/profiles/${encodeURIComponent(handle)}`
}
