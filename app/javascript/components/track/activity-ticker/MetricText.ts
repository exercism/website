import { allowedMetricTypes } from './ActivityTicker.types'

// {handle} {METRIC_TEXT} {exercise?}
export const METRIC_TEXT: Record<allowedMetricTypes, string> = {
  publish_solution_metric: 'published a new solution for',
  open_pull_request_metric: 'opened a Pull Request',
  merge_pull_request_metric: 'had a Pull Request merged',
  complete_solution_metric: 'completed',
  start_solution_metric: 'started',
  submit_submission_metric: 'submitted',
}
