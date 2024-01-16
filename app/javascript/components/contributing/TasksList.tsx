import React, { useCallback } from 'react'
import pluralize from 'pluralize'
import { Pagination } from '@/components/common'
import { useDeepMemo } from '@/hooks/use-deep-memo'
import {
  usePaginatedRequestQuery,
  type Request as BaseRequest,
} from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { ResultsZone } from '@/components/ResultsZone'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { TrackSelect } from '@/components/common/TrackSelect'
import {
  ActionSwitcher,
  TypeSwitcher,
  SizeSwitcher,
  KnowledgeSwitcher,
  ModuleSwitcher,
  ResetButton,
  Sorter,
  Task,
} from './tasks-list'
import type {
  Task as TaskProps,
  Track,
  TaskAction,
  TaskType,
  TaskSize,
  TaskKnowledge,
  TaskModule,
  PaginatedResult,
} from '@/components/types'
import { scrollToTop } from '@/utils/scroll-to-top'

const DEFAULT_ERROR = new Error('Unable to pull tasks')
const DEFAULT_ORDER = 'newest'

type QueryValueTypes = {
  trackSlug: string
  actions: TaskAction[]
  types: TaskType[]
  sizes: TaskSize[]
  knowledge: TaskKnowledge[]
  areas: TaskModule[]
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

export default function TasksList({
  request: initialRequest,
  tracks,
}: {
  request: Request
  tracks: readonly Track[]
}): JSX.Element {
  const { request, setPage, setQuery, setOrder } = useList(initialRequest)
  const {
    status,
    data: resolvedData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<PaginatedResult<TaskProps[]>, Error | Response>(
    ['contributing-tasks', request.endpoint, request.query],
    request
  )

  const track =
    tracks.find((t) => t.slug === request.query.trackSlug) || tracks[0]
  const isFiltering =
    request.query.trackSlug ||
    request.query.actions.length > 0 ||
    request.query.types.length > 0 ||
    request.query.sizes.length > 0 ||
    request.query.knowledge.length > 0 ||
    request.query.areas.length > 0

  const requestQuery = useDeepMemo(request.query)

  const setQueryValue = useCallback(
    <K extends keyof QueryValueTypes>(key: K, value: QueryValueTypes[K]) => {
      setQuery({ ...requestQuery, [key]: value, page: undefined })
    },
    [requestQuery, setQuery]
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
    <div data-scroll-top-anchor="tasks-list" className="lg-container container">
      <div className="c-search-bar">
        <TrackSelect
          tracks={tracks}
          value={track}
          setValue={(track) => setQueryValue('trackSlug', track.slug)}
          size="multi"
        />
        <ActionSwitcher
          value={request.query.actions}
          setValue={(actions) => setQueryValue('actions', actions)}
        />
        <TypeSwitcher
          value={request.query.types}
          setValue={(types) => setQueryValue('types', types)}
        />
        <SizeSwitcher
          value={request.query.sizes}
          setValue={(sizes) => setQueryValue('sizes', sizes)}
        />
        <KnowledgeSwitcher
          value={request.query.knowledge}
          setValue={(knowledge) => setQueryValue('knowledge', knowledge)}
        />
        <ModuleSwitcher
          value={request.query.areas}
          setValue={(modules) => setQueryValue('areas', modules)}
        />
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
                  disabled={resolvedData === undefined}
                  current={request.query.page || 1}
                  total={resolvedData.meta.totalPages}
                  setPage={(p) => {
                    setPage(p)
                    scrollToTop('tasks-list', 32)
                  }}
                />
              </div>
            </React.Fragment>
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}
