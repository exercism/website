import React, { useCallback } from 'react'
import { GraphicalIcon, Pagination } from '../common'
import { Task } from './tasks-list/Task'
import { usePaginatedRequestQuery, Request } from '../../hooks/request-query'
import { useIsMounted } from 'use-is-mounted'
import {
  Task as TaskProps,
  PaginatedResult,
  Track,
  TaskAction,
  TaskType,
  TaskSize,
  TaskKnowledge,
  TaskModule,
} from '../types'
import { ResultsZone } from '../ResultsZone'
import { FetchingBoundary } from '../FetchingBoundary'
import { useList } from '../../hooks/use-list'
import { TrackSwitcher } from '../common/TrackSwitcher'
import { ActionSwitcher } from './tasks-list/ActionSwitcher'
import { TypeSwitcher } from './tasks-list/TypeSwitcher'
import { SizeSwitcher } from './tasks-list/SizeSwitcher'
import { KnowledgeSwitcher } from './tasks-list/KnowledgeSwitcher'
import { ModuleSwitcher } from './tasks-list/ModuleSwitcher'

const DEFAULT_ERROR = new Error('Unable to pull tasks')

export const TasksList = ({
  request: initialRequest,
  tracks,
}: {
  request: Request
  tracks: readonly Track[]
}): JSX.Element => {
  const isMountedRef = useIsMounted()
  const { request, setPage, setQuery } = useList(initialRequest)
  const {
    status,
    resolvedData,
    latestData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<
    PaginatedResult<readonly TaskProps[]>,
    Error | Response
  >(
    ['contributing-tasks', request.endpoint, request.query],
    request,
    isMountedRef
  )
  const track = tracks.find((t) => t.id === request.query.track) || tracks[0]

  const setTrack = useCallback(
    (track: Track) => {
      setQuery({ ...request.query, track: track.id })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setActions = useCallback(
    (actions: TaskAction[]) => {
      setQuery({ ...request.query, actions: actions })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setTypes = useCallback(
    (types: TaskType[]) => {
      setQuery({ ...request.query, types: types })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setSizes = useCallback(
    (sizes: TaskSize[]) => {
      setQuery({ ...request.query, sizes: sizes })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setKnowledge = useCallback(
    (knowledge: TaskKnowledge[]) => {
      setQuery({ ...request.query, knowledge: knowledge })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setModules = useCallback(
    (modules: TaskModule[]) => {
      setQuery({ ...request.query, areas: modules })
    },
    [JSON.stringify(request.query), setQuery]
  )

  return (
    <div className="lg-container container">
      <div className="c-search-bar">
        <TrackSwitcher tracks={tracks} value={track} setValue={setTrack} />
        <ActionSwitcher
          value={request.query.actions || []}
          setValue={setActions}
        />
        <TypeSwitcher value={request.query.types || []} setValue={setTypes} />
        <SizeSwitcher value={request.query.sizes || []} setValue={setSizes} />
        <KnowledgeSwitcher
          value={request.query.knowledge || []}
          setValue={setKnowledge}
        />
        <ModuleSwitcher
          value={request.query.areas || []}
          setValue={setModules}
        />
      </div>
      <header className="main-header c-search-bar">
        <h2>
          <strong>Showing 7,195 tasks out of 7,195 possible tasks</strong>
        </h2>
        <button className="btn-m btn-link reset-btn">
          <GraphicalIcon icon="reset" />
          <span>Reset Filters</span>
        </button>
        <div className="c-select">
          <select>
            <option>Sort by most recent</option>
          </select>
        </div>
      </header>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <React.Fragment>
              <div className="tasks">
                {resolvedData.results.map((task) => (
                  <Task task={task} key={task.id} />
                ))}
                <Pagination
                  disabled={latestData === undefined}
                  current={request.query.page}
                  total={resolvedData.meta.totalPages}
                  setPage={setPage}
                />
              </div>
            </React.Fragment>
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}
