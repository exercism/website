import { Metric } from '@/components/types'

export type ActivityTickerProps = { trackTitle: string; initialData: Metric }

export const METRIC_TYPES = [
  'publish_solution_metric',
  'open_pull_request_metric',
  'merge_pull_request_metric',
  'start_solution_metric',
  'submit_submission_metric',
  'complete_solution_metric',
] as const

export type allowedMetricTypes = typeof METRIC_TYPES[number]
