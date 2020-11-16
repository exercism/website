import React, { useRef, useEffect, useReducer } from 'react'
import { usePopper } from 'react-popper'
import { useQuery } from 'react-query'
import { Loading } from '../common/Loading'

type TooltipState = {
  requestHover: boolean
  requestFocus: boolean
  hover: boolean
  focus: boolean
  show: boolean
}

type HideOrShow = 'hide' | 'show'

type ShowAction =
  | ForceCloseAction
  | RequestShowFromRefHoverAction
  | RequestShowFromRefFocusAction
  | ShowFromHoverAction
  | ShowFromFocusAction

type ForceCloseAction = {
  type: 'force-close'
  value: null
}

type RequestShowFromRefHoverAction = {
  type: 'request-show-from-ref-hover'
  value: HideOrShow
}

type RequestShowFromRefFocusAction = {
  type: 'request-show-from-ref-focus'
  value: HideOrShow
}

type ShowFromHoverAction = {
  type: 'show-hover'
  value: HideOrShow
}

type ShowFromFocusAction = {
  type: 'show-focus'
  value: HideOrShow
}

type DispatchAction = {
  id: string
  dispatch: React.Dispatch<unknown>
  action: ShowAction
}

type OpenTooltip = [string, React.Dispatch<unknown>]

interface ShowReducer {
  (state: TooltipState, payload: DispatchAction): TooltipState
}

interface ConceptProps {
  contentEndpoint: string
  hoverRequestToShow: boolean
  focusRequestToShow: boolean
  referenceElement: HTMLElement | null
  referenceConceptSlug: string
}

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
  openTooltips.forEach(([openId, openDispatch]) => {
    if (openId !== id) {
      openDispatch({
        id: openId,
        dispatch: openDispatch,
        source: 'force-close',
      })
    }
  })
}

/**
 * tooltipReducer
 * This serves as a state reducer for the Concept (tooltip) Component for use with
 * the useReducer hook.
 */
const tooltipReducer: ShowReducer = function (state, action) {
  const {
    id,
    dispatch,
    action: { type, value = null },
  } = action

  const nextState: TooltipState = { ...state }
  const nextShow = (state: TooltipState): boolean =>
    state.requestHover || state.requestFocus || state.hover || state.focus
  const shouldShow = value === 'show'

  switch (type) {
    case 'request-show-from-ref-hover':
      nextState.requestHover = shouldShow && !hasOpenTooltip(id)
      nextState.show = nextShow(nextState)
      break
    case 'request-show-from-ref-focus':
      nextState.requestFocus = shouldShow
      nextState.show = nextShow(nextState)
      break
    case 'show-hover':
      nextState.hover = shouldShow && !hasOpenTooltip(id)
      nextState.show = nextShow(nextState)
      break
    case 'show-focus':
      nextState.focus = shouldShow
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
    (type === 'request-show-from-ref-focus' || type === 'show-focus') &&
    nextState.show &&
    hasOpenTooltip(id)
  ) {
    closeOtherOpenTooltips(id)
  }

  return nextState
}

export const Concept = ({
  contentEndpoint,
  hoverRequestToShow,
  focusRequestToShow,
  referenceElement,
  referenceConceptSlug,
}: ConceptProps): JSX.Element => {
  const tooltipId = `concept-tooltip${
    referenceConceptSlug ? `-${referenceConceptSlug}` : referenceConceptSlug
  }`
  // Retrieve the HTML contents from the contentEndpoint
  const { isLoading, isError, data: html_content } = useQuery<string>(
    tooltipId,
    () => fetch(contentEndpoint).then((res) => res.text())
  )

  const tooltipRef = useRef(null)
  const [{ show }, dispatch] = useReducer(tooltipReducer, {
    requestHover: false,
    requestFocus: false,
    hover: false,
    focus: false,
    show: false,
  })

  const popper = usePopper(referenceElement, tooltipRef.current, {
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
      dispatch({
        id: tooltipId,
        dispatch: dispatch as React.Dispatch<unknown>,
        action: {
          type: 'request-show-from-ref-hover',
          value: 'show',
        },
      })
      return
    }

    const timeoutRef = setTimeout(
      () =>
        dispatch({
          id: tooltipId,
          dispatch: dispatch as React.Dispatch<unknown>,
          action: {
            type: 'request-show-from-ref-hover',
            value: 'hide',
          },
        }),
      150
    )

    return () => {
      clearTimeout(timeoutRef)
    }
  }, [hoverRequestToShow]) // eslint-disable-line react-hooks/exhaustive-deps

  useEffect(() => {
    if (focusRequestToShow && popper?.update) {
      popper.update()
      dispatch({
        id: tooltipId,
        dispatch: dispatch as React.Dispatch<unknown>,
        action: {
          type: 'request-show-from-ref-focus',
          value: 'show',
        },
      })
      return
    }

    dispatch({
      id: tooltipId,
      dispatch: dispatch as React.Dispatch<unknown>,
      action: {
        type: 'request-show-from-ref-focus',
        value: 'hide',
      },
    })
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
  if (isLoading || isError || html_content === undefined) {
    return (
      <div
        ref={tooltipRef}
        className={classNames.join(' ')}
        style={styles}
        {...popper.attributes.popper}
        role="tooltip"
      >
        {isLoading && <Loading />}
        {(isError || html_content === undefined) && <p>Something went wrong</p>}
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
        dispatch({
          id: tooltipId,
          dispatch: dispatch as React.Dispatch<unknown>,
          action: {
            type: 'show-focus',
            value: 'show',
          },
        })
      }}
      onBlur={() => {
        dispatch({
          id: tooltipId,
          dispatch: dispatch as React.Dispatch<unknown>,
          action: {
            type: 'show-focus',
            value: 'hide',
          },
        })
      }}
      onMouseEnter={() =>
        dispatch({
          id: tooltipId,
          dispatch: dispatch as React.Dispatch<unknown>,
          action: {
            type: 'show-hover',
            value: 'show',
          },
        })
      }
      onMouseLeave={() =>
        dispatch({
          id: tooltipId,
          dispatch: dispatch as React.Dispatch<unknown>,
          action: {
            type: 'show-hover',
            value: 'hide',
          },
        })
      }
      dangerouslySetInnerHTML={{ __html: html_content }}
    ></div>
  )
}
