import React from 'react'
import pluralize from 'pluralize'

export function Header({ data, query = {} }) {
  const isFiltering = query.criteria || (query.tags && query.tags.length > 0)

  return (
    <h2>
      {isFiltering
        ? `Showing ${pluralize('track', data.tracks.length, true)}`
        : "Exercism's Language Tracks"}{' '}
    </h2>
  )
}
