import React, { useEffect, useReducer, useState } from 'react'
import { usePopper } from 'react-popper'
import { useQuery } from 'react-query'

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

interface TooltipProps {
  id: string
  className: string
  referenceElement: HTMLElement | null
  contentEndpoint: string
  hoverRequestToShow: boolean
  focusRequestToShow: boolean
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

const addOpenTooltip = (id: string, dispatcher: React.Dispatch<unknown>) => {
  if (openTooltips.find(([openId]) => openId === id)) {
    return
  }

  openTooltips.push([id, dispatcher])
}

const removeOpenTooltip = (id: string) => {
  const index = indexOfOpenTooltip(id)
  if (index !== -1) {
    openTooltips.splice(index, 1)
  }
}

const closeOtherOpenTooltips = (id: string) => {
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

export const Tooltip = ({
  id,
  className,
  referenceElement,
  contentEndpoint,
  hoverRequestToShow,
  focusRequestToShow,
}: TooltipProps): JSX.Element | null => {
  const [tooltipElement, setTooltipElement] = useState<HTMLElement | null>(null)

  const [{ showState }, dispatch] = useReducer(
    tooltipReducer,
    null,
    initialTooltipState
  )

  const popper = usePopper(referenceElement, tooltipElement, {
    placement: 'bottom',
    // The line below controls the offset appearance of the tooltip from the reference element
    modifiers: [{ name: 'offset', options: { offset: [0, 8] } }],
  })

  // Retrieve the HTML contents from the contentEndpoint
  const { isLoading, isError, data: htmlContent } = useQuery<string>(
    id,
    () => {
      const controller = new AbortController()
      const signal = controller.signal
      return Object.assign(
        // Create a fetch request for the tooltip content, assign the abort controller to the promise
        // https://react-query.tanstack.com/docs/guides/query-cancellation#using-fetch
        fetch(contentEndpoint, {
          method: 'get',
          signal,
        }).then((res) => res.text()),
        { cancel: () => controller.abort() }
      )
    },
    {
      // Enable the query to fetch only if it isn't in a hidden or error state
      enabled: showState != 'hidden' && showState != 'error',
    }
  )

  // useEffect for responding to the reference element's request to show when hovered
  useEffect(() => {
    if (hoverRequestToShow) {
      dispatch({
        id: id,
        action: {
          type: 'request-show-from-ref-hover',
        },
      })
      return
    }

    // setTimeout used to fire this dispatch AFTER the tooltip
    // self-hever has time to fire
    const timeoutRef = setTimeout(() => {
      dispatch({
        id: id,
        action: {
          type: 'request-hide-from-ref-hover',
        },
      })
    }, 0)

    return () => {
      clearTimeout(timeoutRef)
    }
  }, [hoverRequestToShow, id])

  // useEffect for responding to the reference element's request to show when focused
  useEffect(() => {
    if (focusRequestToShow) {
      dispatch({
        id: id,
        action: {
          type: 'request-show-from-ref-focus',
        },
      })
      return
    }

    // setTimeout used to fire this dispatch AFTER the tooltip
    // self-focus has time to fire
    const timeoutRef = setTimeout(() => {
      dispatch({
        id: id,
        action: {
          type: 'request-hide-from-ref-focus',
        },
      })
    }, 0)

    return () => {
      clearTimeout(timeoutRef)
    }
  }, [focusRequestToShow, id])

  // useEffect for responding to the tooltips internal state
  useEffect(() => {
    if (isError) {
      removeOpenTooltip(id)

      dispatch({
        id: id,
        action: {
          type: 'error',
        },
      })
    }

    switch (showState) {
      case 'loading':
        if (isLoading) {
          return
        }
        dispatch({
          id: id,
          action: {
            type: 'loaded',
          },
        })
        break
      case 'invisible':
        addOpenTooltip(id, dispatch as React.Dispatch<unknown>)
        dispatch({
          id: id,
          action: {
            type: 'show',
          },
        })
        break
      case 'visible':
        closeOtherOpenTooltips(id)
        break
      case 'hidden':
        removeOpenTooltip(id)
        break
    }

    // TODO: 🔥 I think this needs a cleanup, but this seems to cause problems
    // return () => {
    //   dispatch({
    //     id: tooltipId,
    //     action: {
    //       type: 'hide',
    //     },
    //   })
    // }
  }, [showState, id, isLoading, isError])

  // short-circuit return null if not ready to display the tooltip
  if ((showState !== 'visible' && showState !== 'invisible') || !htmlContent) {
    return null
  }

  // Get styles and classes to apply
  const styles = { ...popper.styles.popper, zIndex: 10 }
  const classNames = ['c-tooltip', className]
  if (showState === 'invisible') {
    classNames.push('tw-invisible')
  }
  if (showState === 'visible') {
    classNames.push('tw-pointer-events-auto')
  }

  return (
    <div
      ref={setTooltipElement}
      className={classNames.join(' ')}
      style={styles}
      {...popper.attributes.popper}
      role="tooltip"
      tabIndex={showState === 'visible' ? undefined : -1}
      onFocus={() => {
        dispatch({
          id: id,
          action: {
            type: 'request-show-focus',
          },
        })
      }}
      onBlur={() => {
        dispatch({
          id: id,
          action: {
            type: 'request-hide-focus',
          },
        })
      }}
      onMouseEnter={() =>
        dispatch({
          id: id,
          action: {
            type: 'request-show-hover',
          },
        })
      }
      onMouseLeave={() =>
        dispatch({
          id: id,
          action: {
            type: 'request-hide-hover',
          },
        })
      }
      dangerouslySetInnerHTML={{ __html: htmlContent }}
    ></div>
  )
}
