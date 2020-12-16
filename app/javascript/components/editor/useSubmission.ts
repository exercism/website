import { useReducer } from 'react'
import { APIError } from '../../utils/send-request'
import { Submission, TestRun, TestRunStatus } from './types'

type State = {
  submission?: Submission
  status?: SubmissionStatus
  apiError: APIError | null
}

export enum ActionType {
  CREATING_SUBMISSION = 'creatingSubmission',
  SUBMISSION_CREATED = 'submissionCreated',
  CREATING_ITERATION = 'creatingIteration',
  SUBMISSION_CANCELLED = 'submissionCancelled',
  SUBMISSION_CHANGED = 'submissionChanged',
}

export enum SubmissionStatus {
  CREATING = 'creating',
  CREATED = 'created',
  CANCELLED = 'cancelled',
  CREATING_ITERATION = 'creating_iteration',
}

type Action =
  | { type: ActionType.CREATING_SUBMISSION }
  | {
      type: ActionType.SUBMISSION_CREATED
      payload: { submission: Submission }
    }
  | { type: ActionType.SUBMISSION_CANCELLED; payload?: { apiError?: APIError } }
  | { type: ActionType.CREATING_ITERATION }
  | {
      type: ActionType.SUBMISSION_CHANGED
      payload: { testRun: TestRun }
    }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case ActionType.CREATING_SUBMISSION:
      return {
        ...state,
        apiError: null,
        status: SubmissionStatus.CREATING,
      }
    case ActionType.SUBMISSION_CREATED:
      return {
        ...state,
        submission: {
          ...action.payload.submission,
          testRun: {
            id: null,
            submissionUuid: action.payload.submission.uuid,
            status: TestRunStatus.QUEUED,
            tests: [],
            message: '',
          },
        },
        status: SubmissionStatus.CREATED,
      }
    case ActionType.SUBMISSION_CANCELLED:
      return {
        ...state,
        apiError: action.payload?.apiError || null,
        status: SubmissionStatus.CANCELLED,
      }
    case ActionType.CREATING_ITERATION:
      return {
        ...state,
        status: SubmissionStatus.CREATING_ITERATION,
      }
    case ActionType.SUBMISSION_CHANGED:
      return {
        ...state,
        submission: {
          ...(state.submission as Submission),
          testRun: action.payload.testRun,
        },
      }
    default:
      return state
  }
}

export const useSubmission = (submission?: Submission) => {
  return useReducer(reducer, { submission: submission, apiError: null })
}
