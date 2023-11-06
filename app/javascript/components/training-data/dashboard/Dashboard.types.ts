import type { Request as BaseRequest, Request } from '@/hooks/request-query'
import { useDashboardReturnType } from './useDashboard'

export type DashboardProps = {
  tracksRequest: Request
  trainingDataRequest: TrainingDataRequest
  statuses: TrainingDataStatuses
}

export type TrainingDataStatus =
  | 'untagged'
  | 'machine_tagged'
  | 'human_tagged'
  | 'community_checked'
  | 'admin_checked'

export type DashboardHeaderProps = Pick<
  useDashboardReturnType,
  'setTrack' | 'criteria' | 'setCriteria' | 'setOrder' | 'setPage' | 'request'
> & {
  tracksRequest: BaseRequest
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
  createdAt: string
  updatedAt: string
  links: {
    self: string
  }
}

export type TrainingDataStatuses = TrainingDataStatus[]
