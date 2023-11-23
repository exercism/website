import { allowedMetricTypes } from './ActivityTicker.types'

// {handle} {METRIC_TEXT} {exercise?}
export const METRIC_TEXT: Record<allowedMetricTypes, string> = {
  publish_solution_metric: 'published a new solution for',
  open_pull_request_metric: "submitted a Pull Request on Exercism's GitHub",
  merge_pull_request_metric: "had a Pull Request merged on Exercism's GitHub",
  complete_solution_metric: 'completed',
  start_solution_metric: 'started',
  submit_submission_metric: 'ran the tests for',
}
