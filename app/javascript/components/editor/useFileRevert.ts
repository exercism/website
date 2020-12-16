import { useReducer } from 'react'
import { APIError } from '../../utils/send-request'

type State = {
  status: RevertStatus
  apiError: APIError | null
}

export enum RevertStatus {
  NONE = 'none',
  INITIALIZED = 'initialized',
  SUCCEEDED = 'succeeded',
  FAILED = 'failed',
}

type Action =
  | { type: RevertStatus.NONE }
  | { type: RevertStatus.INITIALIZED }
  | { type: RevertStatus.SUCCEEDED }
  | { type: RevertStatus.FAILED; payload: { apiError: APIError } }

function reducer(state: State, action: Action): State {
  switch (action.type) {
    case RevertStatus.INITIALIZED:
      return { status: RevertStatus.INITIALIZED, apiError: null }
    case RevertStatus.SUCCEEDED:
      return { status: RevertStatus.SUCCEEDED, apiError: null }
    case RevertStatus.FAILED:
      return { status: RevertStatus.FAILED, apiError: action.payload.apiError }
    default:
      return state
  }
}

export const useFileRevert = () => {
  return useReducer(reducer, { status: RevertStatus.NONE, apiError: null })
}
