import React from 'react'
import type { MetricUser } from '@/components/types'

export function Handle({
  user,
  countryName,
}: {
  user?: MetricUser
  countryName: string
}) {
  if (!user) return `Someone${countryName ? ' in ' + countryName : ''}`

  const { handle, links } = user

  return links?.self ? (
    <a href={links.self} className="text-prominentLinkColor font-semibold">
      {handle}
    </a>
  ) : (
    <span className="font-semibold">{handle}</span>
  )
}
