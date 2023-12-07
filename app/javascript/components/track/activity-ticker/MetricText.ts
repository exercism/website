import { allowedMetricTypes } from './ActivityTicker.types'

// {handle} {METRIC_TEXT} {exercise? | pull_request?}
export const METRIC_TEXT: Record<allowedMetricTypes, string> = {
  publish_solution_metric: 'published a',
  open_pull_request_metric: 'opened a',
  merge_pull_request_metric: 'merged a',
  complete_solution_metric: 'completed',
  start_solution_metric: 'started',
  submit_submission_metric: 'attempted',
}
