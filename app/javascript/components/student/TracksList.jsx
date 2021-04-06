import React, { useReducer } from 'react'
import { usePaginatedRequestQuery } from '../../hooks/request-query'
import { Search } from './tracks-list/Search'
import { TagsFilter } from './tracks-list/TagsFilter'
import { List } from './tracks-list/List'
import { useIsMounted } from 'use-is-mounted'
import { FetchingOverlay } from '../FetchingOverlay'

function reducer(state, action) {
  switch (action.type) {
    case 'criteria.changed':
      return {
        ...state,
        query: { ...state.query, criteria: action.payload.criteria },
        options: { ...state.options, initialData: undefined },
      }
    case 'status.changed':
      return {
        ...state,
        query: { ...state.query, status: action.payload.status },
        options: { ...state.options, initialData: undefined },
      }
    case 'tags.changed':
      return {
        ...state,
        query: { ...state.query, tags: action.payload.tags },
        options: { ...state.options, initialData: undefined },
      }
  }
}

export function TracksList({ statusOptions, tagOptions, ...props }) {
  const isMountedRef = useIsMounted()
  const [request, dispatch] = useReducer(reducer, props.request)
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

  return (
    <div className="c-tracks-list">
      <section className="c-search-bar">
        <div className="lg-container container">
          <Search dispatch={dispatch} />
          <TagsFilter
            dispatch={dispatch}
            options={tagOptions}
            numTracks={resolvedData ? resolvedData.tracks.length : 0}
          />
          <div className="c-select">
            <select>
              <option>Recommended</option>
            </select>
          </div>
        </div>
      </section>
      <section className="lg-container container">
        {isError && <p>Something went wrong</p>}
        {resolvedData && (
          <FetchingOverlay isFetching={isFetching}>
            <List data={resolvedData} />
          </FetchingOverlay>
        )}
      </section>
    </div>
  )
}
