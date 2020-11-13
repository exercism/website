import React, { useRef, useEffect, useReducer } from 'react'
import { usePopper } from 'react-popper'
import { useQuery } from 'react-query'
import { Loading } from '../common/Loading'

type ShowState = {
  requestHover: boolean
  requestFocus: boolean
  hover: boolean
  focus: boolean
  show: boolean
}

type ShowActionSource =
  | 'force-close'
  | 'request-hover'
  | 'request-focus'
  | 'hover'
  | 'focus'

type ShowActionValue = 'show' | 'hide'

type OpenTooltip = [string, React.Dispatch<unknown>]

/**
 * OpenTooltips maintains an array of open tooltips
 * Only 1 should be active at once, but given the chance of race conditions
 * A array is used to track potentially multiple open
 */

const openTooltips: OpenTooltip[] = []

const indexOfOpenTooltip = (id: string) =>
  openTooltips.findIndex(([openId]) => openId === id)

const hasOpenTooltip = (id: string) =>
  indexOfOpenTooltip(id) === -1
    ? openTooltips.length > 0
    : openTooltips.length > 1

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
  openTooltips.forEach(([openId, openDispatcher]) => {
    if (openId !== id) {
      dispatch(openId, openDispatcher, 'force-close')
    }
  })
}

/**
 * showReducer
 * This serves as a state reducer for the Concept (tooltip) Component for use with
 * the useReducer hook.
 */
function showReducer(
  state: ShowState,
  [id = '', dispatch, source, action]: [
    string,
    React.Dispatch<unknown>,
    ShowActionSource,
    ShowActionValue
  ]
) {
  const nextState: ShowState = { ...state }
  const parsedAction = action === 'show'
  const nextShow = (state: ShowState): boolean =>
    state.requestHover || state.requestFocus || state.hover || state.focus

  switch (source) {
    case 'request-hover':
      nextState.requestHover = parsedAction && !hasOpenTooltip(id)
      nextState.show = nextShow(nextState)
      break
    case 'request-focus':
      nextState.requestFocus = parsedAction
      nextState.show = nextShow(nextState)
      break
    case 'hover':
      nextState.hover = parsedAction && !hasOpenTooltip(id)
      nextState.show = nextShow(nextState)
      break
    case 'focus':
      nextState.focus = parsedAction
      nextState.show = nextShow(nextState)
      break
    case 'force-close':
      nextState.show = false
      break
    default:
      throw new Error('unhandled tooltip show action')
  }

  if (nextState.show) {
    addOpenTooltip(id, dispatch)
  } else {
    removeOpenTooltip(id)
  }

  // request-focus and focus actions take precedence over mouse events
  // so it can close any other for accessibility purposes
  if (
    (source === 'request-focus' || source === 'focus') &&
    nextState.show &&
    hasOpenTooltip(id)
  ) {
    closeOtherOpenTooltips(id)
  }

  return nextState
}

function dispatch(
  id = '',
  dispatcher: React.Dispatch<any>, // eslint-disable-line @typescript-eslint/no-explicit-any
  source: ShowActionSource,
  action?: ShowActionValue
): void {
  dispatcher([id, dispatcher, source, action])
}

export const Concept = ({
  endpoint,
  parent,
  hoverRequestToShow,
  focusRequestToShow,
  parentSlug = '',
}: {
  endpoint: string
  parent: HTMLElement | null
  hoverRequestToShow: boolean
  focusRequestToShow: boolean
  parentSlug?: string
}): JSX.Element => {
  const tooltipId = `concept-tooltip${
    parentSlug ? `-${parentSlug}` : parentSlug
  }`
  // Retrieve the HTML contents from the endpoint
  const { isLoading, isError, data: html_content } = useQuery(tooltipId, () =>
    fetch(endpoint).then((res) => res.text())
  ) as { isLoading: boolean; isError: boolean; data: string }

  const tooltipRef = useRef(null)
  const [{ show }, showDispatcher] = useReducer(showReducer, {
    requestHover: false,
    requestFocus: false,
    hover: false,
    focus: false,
    show: false,
  })

  const popper = usePopper(parent, tooltipRef.current, {
    placement: 'bottom',
    modifiers: [{ name: 'offset', options: { offset: [0, 8] } }],
  })

  // For the next two useEffects:
  // If I ignore the exhaustive deps warning and only have requestToShow, it
  // works.  If I have the exhaustive deps added (popper) it causes inf loop
  // due to popper reference changing on every render.

  useEffect(() => {
    if (hoverRequestToShow && popper?.update) {
      popper.update()
      dispatch(tooltipId, showDispatcher, 'request-hover', 'show')
      return
    }

    setTimeout(
      () => dispatch(tooltipId, showDispatcher, 'request-hover', 'hide'),
      150
    )
  }, [hoverRequestToShow]) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (focusRequestToShow && popper?.update) {
      popper.update()
      dispatch(tooltipId, showDispatcher, 'request-focus', 'show')
      return
    }

    dispatch(tooltipId, showDispatcher, 'request-focus', 'hide')
  }, [focusRequestToShow]) // eslint-disable-line react-hooks/exhaustive-deps

  // Get styles and classes to apply
  const styles = { ...popper.styles.popper, zIndex: 10 }
  const classNames = ['c-tooltip', 'c-concept-tooltip']
  if (!show) {
    classNames.push('tw-invisible')
  }
  if (show) {
    classNames.push('tw-pointer-events-auto')
  }

  // Separate render exists because happy path needs to render
  // 'dangerouslySetInnerHTML' and this does not.
  if (isLoading || isError) {
    return (
      <div
        ref={tooltipRef}
        className={classNames.join(' ')}
        style={styles}
        {...popper.attributes.popper}
        role="tooltip"
      >
        {isLoading && <Loading />}
        {isError && <p>Something went wrong</p>}
      </div>
    )
  }

  return (
    <div
      ref={tooltipRef}
      className={classNames.join(' ')}
      style={styles}
      {...popper.attributes.popper}
      role="tooltip"
      tabIndex={show ? undefined : -1}
      onFocus={() => {
        dispatch(tooltipId, showDispatcher, 'focus', 'show')
      }}
      onBlur={() => {
        dispatch(tooltipId, showDispatcher, 'focus', 'hide')
      }}
      onMouseEnter={() => dispatch(tooltipId, showDispatcher, 'hover', 'show')}
      onMouseLeave={() => dispatch(tooltipId, showDispatcher, 'hover', 'hide')}
      dangerouslySetInnerHTML={{ __html: html_content }}
    ></div>
  )
}
