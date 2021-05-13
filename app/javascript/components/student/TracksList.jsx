import React, { useCallback } from 'react'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { TagsFilter } from './tracks-list/TagsFilter'
import { List } from './tracks-list/List'
import { useIsMounted } from 'use-is-mounted'
import { ResultsZone } from '../ResultsZone'
import { useList } from '../../hooks/use-list'

export function TracksList({ statusOptions, tagOptions, ...props }) {
  const isMountedRef = useIsMounted()
  const { request, setCriteria, setQuery } = useList(props.request)
  const {
    resolvedData,
    latestData,
    isError,
    isFetching,
  } = usePaginatedRequestQuery(
    ['track-list', request.endpoint, request.query],
    request,
    isMountedRef
  )

  const setTags = useCallback(
    (tags) => {
      setQuery({ ...request.query, tags: tags })
    },
    [request.query, setQuery]
  )

  return (
    <div className="c-tracks-list">
      <section className="c-search-bar">
        <div className="lg-container container">
          <input
            type="text"
            placeholder="Search language tracks"
            className="--search"
            onChange={(e) => setCriteria(e.target.value)}
            value={request.query.criteria}
          />
          <TagsFilter
            setTags={setTags}
            options={tagOptions}
            value={request.query.tags}
            numTracks={resolvedData ? resolvedData.tracks.length : 0}
          />
          <div className="c-select">
            <select>
              <option>Sort by last touched</option>
            </select>
          </div>
        </div>
      </section>
      <section className="lg-container container">
        {isError && <p>Something went wrong</p>}
        {resolvedData && (
          <ResultsZone isFetching={isFetching}>
            <List data={resolvedData} />
          </ResultsZone>
        )}
      </section>
    </div>
  )
}
