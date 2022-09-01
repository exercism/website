import React, { useCallback } from 'react'
import { Pagination } from '../common'
import { Task } from './tasks-list/Task'
import {
  usePaginatedRequestQuery,
  Request as BaseRequest,
} from '../../hooks/request-query'
import {
  Task as TaskProps,
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
import { TrackSelect } from '../common/TrackSelect'
import { ActionSwitcher } from './tasks-list/ActionSwitcher'
import { TypeSwitcher } from './tasks-list/TypeSwitcher'
import { SizeSwitcher } from './tasks-list/SizeSwitcher'
import { KnowledgeSwitcher } from './tasks-list/KnowledgeSwitcher'
import { ModuleSwitcher } from './tasks-list/ModuleSwitcher'
import { ResetButton } from './tasks-list/ResetButton'
import { Sorter } from './tasks-list/Sorter'
import pluralize from 'pluralize'
import { useHistory, removeEmpty } from '../../hooks/use-history'
import useLogger from '../../hooks/use-logger'

const DEFAULT_ERROR = new Error('Unable to pull tasks')
const DEFAULT_ORDER = 'newest'

type PaginatedResult = {
  results: readonly TaskProps[]
  meta: {
    currentPage: number
    totalCount: number
    totalPages: number
    unscopedTotal: number
  }
}

export type TasksListOrder = 'newest' | 'oldest' | 'track'

export type Request = BaseRequest<{
  page: number
  actions: string[]
  knowledge: string[]
  areas: string[]
  sizes: string[]
  types: string[]
  repoUrl: string
  trackSlug: string
  order: string
}>

export const TasksList = ({
  request: initialRequest,
  tracks,
}: {
  request: Request
  tracks: readonly Track[]
}): JSX.Element => {
  const { request, setPage, setQuery, setOrder } = useList(initialRequest)
  const { status, resolvedData, latestData, isFetching, error } =
    usePaginatedRequestQuery<PaginatedResult, Error | Response>(
      ['contributing-tasks', request.endpoint, request.query],
      request
    )
  const track =
    tracks.find((t) => t.slug === request.query.trackSlug) || tracks[0]
  useLogger('TRACK IN TRACKLIST', track)
  const isFiltering =
    request.query.trackSlug ||
    request.query.actions.length > 0 ||
    request.query.types.length > 0 ||
    request.query.sizes.length > 0 ||
    request.query.knowledge.length > 0 ||
    request.query.areas.length > 0

  const setTrack = useCallback(
    (track) => {
      setQuery({ ...request.query, trackSlug: track.slug, page: undefined })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setActions = useCallback(
    (actions: TaskAction[]) => {
      setQuery({ ...request.query, actions: actions, page: undefined })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setTypes = useCallback(
    (types: TaskType[]) => {
      setQuery({ ...request.query, types: types, page: undefined })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setSizes = useCallback(
    (sizes: TaskSize[]) => {
      setQuery({ ...request.query, sizes: sizes, page: undefined })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setKnowledge = useCallback(
    (knowledge: TaskKnowledge[]) => {
      setQuery({ ...request.query, knowledge: knowledge, page: undefined })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const setModules = useCallback(
    (modules: TaskModule[]) => {
      setQuery({ ...request.query, areas: modules, page: undefined })
    },
    [JSON.stringify(request.query), setQuery]
  )

  const handleReset = useCallback(() => {
    setQuery({
      ...request.query,
      page: undefined,
      trackSlug: '',
      actions: [],
      types: [],
      sizes: [],
      knowledge: [],
      areas: [],
    })
  }, [request.query, setQuery])

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <div className="lg-container container">
      <div className="c-search-bar">
        <TrackSelect
          tracks={tracks}
          value={track}
          setValue={setTrack}
          size="multi"
        />
        <ActionSwitcher value={request.query.actions} setValue={setActions} />
        <TypeSwitcher value={request.query.types} setValue={setTypes} />
        <SizeSwitcher value={request.query.sizes} setValue={setSizes} />
        <KnowledgeSwitcher
          value={request.query.knowledge}
          setValue={setKnowledge}
        />
        <ModuleSwitcher value={request.query.areas} setValue={setModules} />
      </div>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <React.Fragment>
              <header className="main-header c-search-bar">
                <h2>
                  <strong className="block md:inline">
                    Showing {resolvedData.meta.totalCount}{' '}
                    {pluralize('task', resolvedData.meta.totalCount)}
                  </strong>
                  <span className="hidden md:inline mr-8">/</span>
                  out of {resolvedData.meta.unscopedTotal} possible{' '}
                  {pluralize('task', resolvedData.meta.unscopedTotal)}
                </h2>
                {isFiltering ? <ResetButton onClick={handleReset} /> : null}
                <Sorter
                  value={request.query.order || DEFAULT_ORDER}
                  setValue={setOrder}
                />
              </header>
              <div className="tasks">
                {resolvedData.results.map((task) => (
                  <Task task={task} key={task.uuid} />
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
