import React, { useEffect, useState } from 'react'
import pluralize from 'pluralize'
import { Loading } from '../../common/Loading'

export function Header({ latestData, query = {} }) {
  const [text, setText] = useState()
  const isFiltering = query.criteria || (query.tags && query.tags.length > 0)
  const isLoading = latestData === undefined

  useEffect(() => {
    if (isLoading) {
      return
    }

    if (isFiltering) {
      setText(`Showing ${pluralize('track', latestData.tracks.length, true)}`)
    } else {
      setText("Exercism's Language Tracks")
    }
  }, [latestData])

  return (
    <div>
      <h2>{text}</h2>
      {isLoading && <Loading />}
    </div>
  )
}
