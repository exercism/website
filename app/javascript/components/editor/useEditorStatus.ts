import { useReducer } from 'react'
import { APIError } from '@/utils/send-request'

export enum EditorStatus {
  INITIALIZED = 'initialized',

  CREATING_SUBMISSION = 'creatingSubmission',
  CREATE_SUBMISSION_FAILED = 'createSubmissionFailed',

  CREATING_ITERATION = 'creatingIteration',

  REVERTING = 'reverting',
  REVERT_FAILED = 'revertFailed',
}

type State = {
  status: EditorStatus
  error: APIError | null
}

type Action =
  | {
      status:
        | EditorStatus.INITIALIZED
        | EditorStatus.CREATING_SUBMISSION
        | EditorStatus.CREATING_ITERATION
        | EditorStatus.REVERTING
    }
  | {
      status: EditorStatus.CREATE_SUBMISSION_FAILED | EditorStatus.REVERT_FAILED
      error: APIError | null
    }

const reducer = (state: State, action: Action): State => {
  switch (action.status) {
    case EditorStatus.INITIALIZED:
    case EditorStatus.CREATING_SUBMISSION:
    case EditorStatus.CREATING_ITERATION:
    case EditorStatus.REVERTING:
      return { status: action.status, error: null }
    case EditorStatus.CREATE_SUBMISSION_FAILED:
    case EditorStatus.REVERT_FAILED:
      return { status: action.status, error: action.error }
  }
}

export const useEditorStatus = () => {
  return useReducer(reducer, { status: EditorStatus.INITIALIZED, error: null })
}
