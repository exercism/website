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
  Track,
  Exercise,
  TaskAction,
  TaskType,
  TaskSize,
  TaskKnowledge,
  TaskModule,
  PaginatedResult,
} from '@/components/types'
import { scrollToTop } from '@/utils/scroll-to-top'

const DEFAULT_ERROR = new Error('Unable to pull approaches')
const DEFAULT_ORDER = 'newest'

type QueryValueTypes = {
  trackSlug: string
  exerciseSlug: string
}
export type ApproachesListOrder = 'newest' | 'oldest' | 'track' | 'exercise'

export type Request = BaseRequest<{
  page: number
  trackSlug: string
  exerciseSlug: string
}>

export default function ApproachesList({
  request: initialRequest,
  tracks,
  exercises,
}: {
  request: Request
  tracks: readonly Track[]
  exercises: readonly Exercise[]
}): JSX.Element {
  return <p>Test</p>
}
