import React, { useEffect, useState } from 'react'
import pluralize from 'pluralize'
import { Loading } from '../../common/Loading'

export function Header({ data, query = {} }) {
  const [text, setText] = useState("Exercism's Language Tracks")
  const isFiltering = query.criteria || (query.tags && query.tags.length > 0)
  const isLoading = data === undefined

  useEffect(() => {
    if (isLoading) {
      return
    }

    if (isFiltering) {
      setText(`Showing ${pluralize('track', data.tracks.length, true)}`)
    } else {
      setText("Exercism's Language Tracks")
    }
  }, [data])

  return (
    <div>
      <h2>{text}</h2>
      {isLoading && <Loading />}
    </div>
  )
}
