import React from 'react'
import type { MetricUser } from '@/components/types'

export function Handle({ user }: { user?: MetricUser }) {
  if (!user) return 'Someone'

  const { handle, links } = user

  return links?.self ? (
    <a href={links.self} className="text-prominentLinkColor font-semibold">
      {handle}
    </a>
  ) : (
    <span className="font-semibold">{handle}</span>
  )
}
