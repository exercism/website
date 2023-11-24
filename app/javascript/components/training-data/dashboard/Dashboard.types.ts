import type { Request as BaseRequest } from '@/hooks/request-query'
import type { useDashboardReturnType } from './useDashboard'
import type { Track } from '@/components/types'

export type DashboardProps = {
  tracks: Track[]
  trainingDataRequest: TrainingDataRequest
  statuses: TrainingDataStatuses
}

export type TrainingDataStatus =
  | 'needs_tagging'
  | 'needs_checking'
  | 'needs_checking_admin'

export type DashboardHeaderProps = Pick<
  useDashboardReturnType,
  'setTrack' | 'criteria' | 'setCriteria' | 'request'
> & {
  tracks: Track[]
}

export type TrainingDataRequest = BaseRequest<{
  status: TrainingDataStatus
  order?: string
  criteria?: string
  page?: number
  trackSlug?: string
}>

export type TrainingDataRequestAPIResponse = {
  results: readonly TrainingData[]
  meta: {
    currentPage: number
    totalPages: number
    awaitingMentorTotal: number
    awaitingStudentTotal: number
    finishedTotal: number
  }
}

export type TrainingData = {
  uuid: string
  status: TrainingDataStatus
  track: {
    title: string
    iconUrl: string
  }
  exercise: {
    title: string
    iconUrl: string
  }
  links: {
    edit: string
  }
}

export type TrainingDataStatuses = TrainingDataStatus[]
