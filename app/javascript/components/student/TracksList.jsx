import React, { useReducer } from 'react'
import { useRequestQuery } from '../../hooks/request-query'
import { Search } from './tracks-list/Search'
import { TagsFilter } from './tracks-list/TagsFilter'
import { List } from './tracks-list/List'
import { useIsMounted } from 'use-is-mounted'
import pluralize from 'pluralize'

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
  const { data, isError, isFetching } = useRequestQuery(
    'track-list',
    request,
    isMountedRef
  )

  return (
    <div className="c-tracks-list">
      <section className="c-search-bar">
        <div className="lg-container container">
          <Search dispatch={dispatch} />
          {data && (
            <p>
              Showing {data.tracks.length} {pluralize('track', data.length)}
            </p>
          )}
          <TagsFilter dispatch={dispatch} options={tagOptions} />
          <div className="c-select">
            <select>
              <option>Recommended</option>
            </select>
          </div>
        </div>
      </section>
      <section className="lg-container container">
        {isError && <p>Something went wrong</p>}
        {data && <List data={data} />}
      </section>
    </div>
  )
}
