import React, { useState, useEffect } from 'react'
import { usePaginatedRequestQuery, type Request } from '@/hooks/request-query'
import { useHistory, removeEmpty } from '@/hooks/use-history'
import { useList } from '@/hooks/use-list'
import { scrollToTop } from '@/utils/scroll-to-top'
import { Icon, Pagination } from '@/components/common'
import CommunitySolution from '../common/CommunitySolution'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { ResultsZone } from '@/components/ResultsZone'
import { OrderSelect } from './exercise-community-solutions-list/OrderSelect'
import type {
  CommunitySolution as CommunitySolutionProps,
  PaginatedResult,
} from '@/components/types'
import { ExerciseTagFilter } from './exercise-community-solutions-list/exercise-tag-filter/ExerciseTagFilter'
import { assembleClassNames } from '@/utils/assemble-classnames'
import { useLocalStorage } from '@/utils/use-storage'
import { LayoutSelect } from './exercise-community-solutions-list/LayoutSelect'

export type Order =
  | 'most_popular'
  | 'newest'
  | 'oldest'
  | 'fewest_loc'
  | 'highest_reputation'
export type SyncStatus = undefined | 'up_to_date' | 'out_of_date'
export type TestsStatus =
  | undefined
  | 'not_queued'
  | 'queued'
  | 'passed'
  | 'failed'
  | 'errored'
  | 'exceptioned'
  | 'cancelled'

const DEFAULT_ERROR = new Error('Unable to pull solutions')
const DEFAULT_ORDER: Order = 'most_popular'

export function ExerciseCommunitySolutionsList({
  request: initialRequest,
  tags,
}: {
  request: Request
  tags: any
}): JSX.Element {
  const {
    request,
    setPage,
    setOrder,
    setQuery,
    setCriteria: setRequestCriteria,
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
    ['exercise-community-solution-list', request.endpoint, request.query],
    request
  )
  const [criteria, setCriteria] = useState(request.query.criteria)
  const [layout, setLayout] = useLocalStorage<`${'grid' | 'lines'}-layout`>(
    'community-solutions-layout',
    'grid-layout'
  )

  useEffect(() => {
    const handler = setTimeout(() => {
      if (
        criteria !== undefined &&
        criteria !== null &&
        (criteria.length >= 3 || criteria.length === 0)
      )
        setRequestCriteria(criteria)
    }, 200)

    return () => {
      clearTimeout(handler)
    }
  }, [setRequestCriteria, criteria])

  useHistory({ pushOn: removeEmpty(request.query) })

  return (
    <div
      data-scroll-top-anchor="exercise-community-solutions-list"
      className="lg-container c-community-solutions-list"
    >
      {resolvedData ? <h2> Explore how others solved this exercise </h2> : null}
      <div className="c-search-bar lg:flex-row flex-col gap-24">
        <input
          className="--search"
          onChange={(e) => {
            setCriteria(e.target.value)
          }}
          value={criteria || ''}
          placeholder="Search by code (min 3 chars)"
        />
        <div className="flex gap-24 md:flex-row flex-col w-100 shrink-2">
          <ExerciseTagFilter
            tags={tags}
            setQuery={setQuery}
            request={request}
          />
          <div className="flex items-center md:w-[unset] w-100 justify-between sm:flex-nowrap flex-wrap sm:gap-y-0 gap-y-24">
            <OrderSelect
              value={request.query.order || DEFAULT_ORDER}
              setValue={setOrder}
            />
          </div>
          <LayoutSelect layout={layout} setLayout={setLayout} />
        </div>
      </div>
      <ResultsZone isFetching={isFetching}>
        <FetchingBoundary
          status={status}
          error={error}
          defaultError={DEFAULT_ERROR}
        >
          {resolvedData ? (
            <React.Fragment>
              <div className={assembleClassNames('solutions', layout)}>
                {MOCK_ARR.map((solution) => {
                  return (
                    <CommunitySolution
                      key={solution.uuid}
                      solution={solution}
                      context="exercise"
                    />
                  )
                })}
              </div>
              <Pagination
                disabled={resolvedData === undefined}
                current={request.query.page || 1}
                total={resolvedData.meta.totalPages}
                setPage={(p) => {
                  setPage(p)
                  scrollToTop('exercise-community-solutions-list', 32)
                }}
              />
            </React.Fragment>
          ) : null}
        </FetchingBoundary>
      </ResultsZone>
    </div>
  )
}

export default ExerciseCommunitySolutionsList

const MOCK_OBJ = {
  uuid: 'a194acd61da8435b9a4765e509eaaba2',
  snippet: `class TwoFer
  def self.two_fer(name = 'you')
    "One for #{name}, one for me."
  end
end
class TwoFer
  def self.two_fer(name = 'you')
    "One for #{name}, one for me."
  end
end
class TwoFer
  def self.two_fer(name = 'you')
    "One for #{name}, one for me."
  end
end
class TwoFer
  def self.two_fer(name = 'you')
    "One for #{name}, one for me."
  end
end`,
  numViews: 0,
  numStars: 0,
  numComments: 0,
  representationNumPublishedSolutions: 2,
  numIterations: 35,
  numLoc: 0,
  iterationStatus: 'essential_automated_feedback',
  publishedIterationHeadTestsStatus: 'passed',
  publishedAt: '2023-10-25T14:17:05.760Z',
  isOutOfDate: false,
  language: 'ruby',
  author: {
    handle: 'insanelyveryLongIhidHandle',
    avatarUrl: '/avatars/720037/1',
    flair: 'staff',
  },
  exercise: {
    title: 'Two Fer',
    iconUrl: 'https://assets.exercism.org/exercises/two-fer.svg',
  },
  track: {
    title: 'Ruby',
    iconUrl: 'https://assets.exercism.org/tracks/ruby.svg',
    highlightjsLanguage: 'ruby',
  },
  links: {
    publicUrl:
      'http://local.exercism.io:3020/tracks/ruby/exercises/two-fer/solutions/insanelyveryLongIhidHandle',
    privateIterationsUrl:
      'http://local.exercism.io:3020/tracks/ruby/exercises/two-fer/iterations',
  },
}

const MOCK_ARR = new Array(24).fill(MOCK_OBJ)
