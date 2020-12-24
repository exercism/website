import { useReducer } from 'react'

type TooltipState = {
  requestHover: boolean
  requestFocus: boolean
  hover: boolean
  focus: boolean
  showState: ShowState
}

type ShowState = 'hidden' | 'loading' | 'invisible' | 'visible' | 'error'

type TooltipAction =
  | ErrorAction
  | RequestShowFromRefHoverAction
  | RequestHideFromRefHoverAction
  | RequestShowFromRefFocusAction
  | RequestHideFromRefFocusAction
  | RequestShowFromHoverAction
  | RequestHideFromHoverAction
  | RequestShowFromFocusAction
  | RequestHideFromFocusAction
  | LoadedAction
  | ShowAction
  | HideAction

type ErrorAction = {
  type: 'error'
}

type RequestShowFromRefHoverAction = {
  type: 'request-show-from-ref-hover'
}

type RequestHideFromRefHoverAction = {
  type: 'request-hide-from-ref-hover'
}

type RequestShowFromRefFocusAction = {
  type: 'request-show-from-ref-focus'
}

type RequestHideFromRefFocusAction = {
  type: 'request-hide-from-ref-focus'
}

type RequestShowFromHoverAction = {
  type: 'request-show-hover'
}

type RequestHideFromHoverAction = {
  type: 'request-hide-hover'
}

type RequestShowFromFocusAction = {
  type: 'request-show-focus'
}

type RequestHideFromFocusAction = {
  type: 'request-hide-focus'
}

type LoadedAction = {
  type: 'loaded'
}

type ShowAction = {
  type: 'show'
}

type HideAction = {
  type: 'hide'
}

type DispatchAction = {
  id: string
  action: TooltipAction
}

type OpenTooltip = [string, React.Dispatch<unknown>]

interface ShowReducer {
  (state: TooltipState, payload: DispatchAction): TooltipState
}

function initialTooltipState(): TooltipState {
  return {
    requestHover: false,
    requestFocus: false,
    hover: false,
    focus: false,
    showState: 'hidden',
  }
}

/**
 * OpenTooltips maintains an array of open tooltips
 * Only 1 should be active at once, but given the chance of race conditions
 * A array is used to track potentially multiple open
 */

const openTooltips: OpenTooltip[] = []

const indexOfOpenTooltip = (id: string) =>
  openTooltips.findIndex(([openId]) => openId === id)

const hasOpenTooltip = (id: string) => {
  return indexOfOpenTooltip(id) === -1
    ? openTooltips.length > 0
    : openTooltips.length > 1
}

const addOpenTooltip = (
  id: string,
  dispatcher: React.Dispatch<unknown>
): void => {
  if (openTooltips.find(([openId]) => openId === id)) {
    return
  }

  openTooltips.push([id, dispatcher])
}

const removeOpenTooltip = (id: string): void => {
  const index = indexOfOpenTooltip(id)
  if (index !== -1) {
    openTooltips.splice(index, 1)
  }
}

const closeOtherOpenTooltips = (id: string): void => {
  openTooltips.forEach(([openId, openDispatch]) => {
    if (openId !== id) {
      openDispatch({
        id: openId,
        action: {
          type: 'hide',
        },
      })
    }
  })
}

const shouldShow = (state: TooltipState): boolean => {
  return state.focus || state.hover || state.requestFocus || state.requestHover
}

const handleShowRequest = (state: TooltipState): ShowState => {
  return shouldShow(state) && state.showState === 'hidden'
    ? 'loading'
    : state.showState
}

const handleHideRequest = (state: TooltipState): ShowState => {
  return !shouldShow(state) ? 'hidden' : state.showState
}

/**
 * tooltipReducer
 * This serves as a state reducer for the <Tooltip /> Component for use with
 * the useReducer hook.
 */
const tooltipReducer: ShowReducer = function (state, body) {
  const { id, action } = body
  const nextState: TooltipState = { ...state }

  // Use action to update the next state
  switch (action.type) {
    case 'request-show-from-ref-hover':
      nextState.requestHover = true && !hasOpenTooltip(id)
      nextState.showState = handleShowRequest(nextState)
      break
    case 'request-hide-from-ref-hover':
      nextState.requestHover = false
      nextState.showState = handleHideRequest(nextState)
      break
    case 'request-show-from-ref-focus':
      nextState.requestFocus = true
      nextState.showState = handleShowRequest(nextState)
      break
    case 'request-hide-from-ref-focus':
      nextState.requestFocus = false
      nextState.showState = handleHideRequest(nextState)
      break
    case 'request-show-hover':
      nextState.hover = true && !hasOpenTooltip(id)
      nextState.showState = handleShowRequest(nextState)
      break
    case 'request-hide-hover':
      nextState.hover = false
      nextState.showState = handleHideRequest(nextState)
      break
    case 'request-show-focus':
      nextState.focus = true
      nextState.showState = handleShowRequest(nextState)
      break
    case 'request-hide-focus':
      nextState.focus = false
      nextState.showState = handleHideRequest(nextState)
      break
    case 'loaded':
      nextState.showState = 'invisible'
      break
    case 'show':
      nextState.showState = 'visible'
      break
    case 'hide':
      nextState.showState = 'hidden'
      break
    case 'error':
      nextState.showState = 'error'
      break
    default:
      throw new Error('unhandled tooltip reducer action')
  }

  return nextState
}

interface UseStatefulTooltip {
  state: TooltipState
  dispatch: React.Dispatch<DispatchAction>
  addOpenTooltip: typeof addOpenTooltip
  removeOpenTooltip: typeof removeOpenTooltip
  closeOtherOpenTooltips: typeof closeOtherOpenTooltips
}

export function useStatefulTooltip(): UseStatefulTooltip {
  const [state, dispatch] = useReducer(
    tooltipReducer,
    null,
    initialTooltipState
  )

  return {
    state,
    dispatch,
    addOpenTooltip,
    removeOpenTooltip,
    closeOtherOpenTooltips,
  }
}

interface DispatchHelper {
  (dispatch: React.Dispatch<DispatchAction>, id: string): void
}

export const dispatchError: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'error' } })

export const dispatchLoaded: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'loaded' } })

export const dispatchShow: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'show' } })

export const dispatchHide: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'hide' } })

export const dispatchRequestHideFromRefHover: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'request-hide-from-ref-hover' } })

export const dispatchRequestHideFromRefFocus: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'request-hide-from-ref-focus' } })

export const dispatchRequestShowFromRefHover: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'request-show-from-ref-hover' } })

export const dispatchRequestShowFromRefFocus: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'request-show-from-ref-focus' } })

export const dispatchRequestHideFromHover: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'request-hide-hover' } })

export const dispatchRequestHideFromFocus: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'request-hide-focus' } })

export const dispatchRequestShowFromHover: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'request-show-hover' } })

export const dispatchRequestShowFromFocus: DispatchHelper = (dispatch, id) =>
  dispatch({ id, action: { type: 'request-show-focus' } })
