import React, { useCallback, useEffect, useState } from 'react'
import { type Request, usePaginatedRequestQuery } from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { scrollToTop } from '@/utils/scroll-to-top'
import { useLocalStorage } from '@/utils/use-storage'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { TrackDropdown } from '../profile/community-solutions-list'
import { TrackData } from '../profile/CommunitySolutionsList'
import { FilterFallback, Pagination } from '../common'
import CommunitySolution from '../common/CommunitySolution'
import { FetchingBoundary } from '../FetchingBoundary'
import { ResultsZone } from '../ResultsZone'
import { LayoutSelect } from '../track/exercise-community-solutions-list/LayoutSelect'
import type {
  CommunitySolution as CommunitySolutionProps,
  PaginatedResult,
} from '../types'
import { TooltipContent, TooltipWrapper } from '../common/FollowTooltip'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type FavoritesListProps = {
  tracks: TrackData[]
  request: Request
  isUserInsider: boolean
}

export default function FavoritesList({
  tracks,
  request: initialRequest,
  isUserInsider,
}: FavoritesListProps) {
  const { t } = useAppTranslation('components/favorites-list')
  const DEFAULT_ERROR = new Error(t('index.defaultError'))
  const {
    request,
    setCriteria: setRequestCriteria,
    setPage,
    setQuery,
  } = useList(initialRequest)

  const {
    status,
    data: resolvedData,
    isFetching,
    error,
  } = usePaginatedRequestQuery<
    PaginatedResult<CommunitySolutionProps[]>,
    Error | Response
  >(
    ['favorite-community-solution-list', request.endpoint, request.query],
    request
  )

  const [criteria, setCriteria] = useState(request.query?.criteria ?? '')
  const [layout, setLayout] = useLocalStorage<`${'grid' | 'lines'}-layout`>(
    'community-solutions-layout',
    'grid-layout'
  )

  const setTrack = useCallback(
    (slug) => {
      setQuery({ ...request.query, trackSlug: slug, page: undefined })
    },
    [request.query, setQuery]
  )

  useEffect(() => {
    const handler = setTimeout(() => {
      if (criteria === undefined || criteria === null) return
      setRequestCriteria(criteria)
    }, 200)

    return () => clearTimeout(handler)
  }, [criteria, setRequestCriteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  if (
    resolvedData?.meta?.unscopedTotal === 0 &&
    Array.isArray(resolvedData.results) &&
    resolvedData.results.length === 0 &&
    !isFetching
  ) {
    return <NoFavoritesYet />
  }

  return (
    <div
      className="lg-container favorite-community-solutions-list"
      data-scroll-top-anchor="favorite-community-solutions-list"
    >
      <div className="flex lg:flex-row flex-col items-start">
        <TooltipWrapper className="c-search-bar w-full lg:flex-row flex-col gap-24 relative group">
          {!isUserInsider && (
            <TooltipContent>
              <span className="rounded-8 px-8 py-2 bg-backgroundColorH text-backgroundColorA text-xs shadow whitespace-nowrap">
                {t('index.filteringRestricted')}
              </span>
            </TooltipContent>
          )}
          {tracks.length > 0 && (
            <TrackDropdown
              tracks={tracks}
              value={request.query?.trackSlug || ''}
              setValue={setTrack}
              disabled={!isUserInsider}
            />
          )}
          <input
            className="--search"
            onChange={(e) => setCriteria(e.target.value)}
            value={criteria}
            placeholder={t('index.searchPlaceholder')}
            disabled={!isUserInsider}
          />
        </TooltipWrapper>
        <LayoutSelect
          className="mb-32 h-full"
          layout={layout}
          setLayout={setLayout}
        />
      </div>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {Array.isArray(resolvedData?.results) &&
          resolvedData.results.length > 0 ? (
            <>
              <div className={assembleClassNames('solutions', layout)}>
                {resolvedData.results.map((solution) => (
                  <CommunitySolution
                    key={solution.uuid}
                    solution={solution}
                    context="exercise"
                  />
                ))}
              </div>
              {typeof resolvedData.meta?.totalPages === 'number' && (
                <Pagination
                  disabled={resolvedData === undefined}
                  current={request.query?.page || 1}
                  total={resolvedData.meta.totalPages}
                  setPage={(p) => {
                    setPage(p)
                    scrollToTop('favorite-community-solutions-list', 32)
                  }}
                />
              )}
            </>
          ) : (
            <NoResults />
          )}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}

function NoResults() {
  const { t } = useAppTranslation('components/favorites-list')
  return (
    <FilterFallback
      icon="no-result-magnifier"
      title={t('index.noResults.title')}
      description={t('index.noResults.description')}
    />
  )
}

function NoFavoritesYet() {
  const { t } = useAppTranslation('components/favorites-list')
  return (
    <FilterFallback
      icon="no-result-magnifier"
      title={t('index.noFavoritesYet.title')}
      description={t('index.noFavoritesYet.description')}
    />
  )
}
