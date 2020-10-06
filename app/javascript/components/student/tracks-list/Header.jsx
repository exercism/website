import React from 'react'

export function Header({ data, query = {} }) {
  const isFiltering = query.criteria || (query.tags && query.tags.length !== 0)

  if (!isFiltering) {
    return <p>Exercism's Language Tracks</p>
  }

  if (data.tracks.length === 1) {
    return <p>Showing 1 track</p>
  } else {
    return <p>Showing {data.tracks.length} tracks</p>
  }
}
