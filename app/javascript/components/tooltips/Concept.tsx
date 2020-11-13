import React, { useRef, useEffect, useReducer } from 'react'
import { usePopper } from 'react-popper'
import { useQuery } from 'react-query'
import { Loading } from '../common/Loading'

type ShowState = {
  request: boolean
  hover: boolean
  focus: boolean
  show: boolean
}
type ShowRequest =
  | { request: boolean }
  | { hover: boolean }
  | { focus: boolean }

function showReducer(state: ShowState, action: ShowRequest) {
  const nextState: ShowState = { ...state, ...action }
  nextState.show = nextState.request || nextState.hover || nextState.focus

  console.log({ state, action, next: nextState })

  return nextState
}

export const Concept = ({
  endpoint,
  parent,
  requestToShow,
}: {
  endpoint: string
  parent: HTMLElement | null
  requestToShow: boolean
}): JSX.Element => {
  const { isLoading, isError, data: html_content } = useQuery(
    'concept-tooltip',
    () => fetch(endpoint).then((res) => res.text())
  ) as { isLoading: boolean; isError: boolean; data: string }

  const tooltipRef = useRef(null)
  const [{ show }, dispatchShow] = useReducer(showReducer, {
    request: false,
    hover: false,
    focus: document.activeElement === tooltipRef.current,
    show: false,
  })
  const popper = usePopper(parent, tooltipRef.current, {
    placement: 'bottom',
    modifiers: [{ name: 'offset', options: { offset: [0, 8] } }],
  })

  useEffect(() => {
    if (requestToShow && popper?.update) {
      popper.update()
      dispatchShow({ request: true })
      return
    }

    dispatchShow({ request: false })
  }, [requestToShow]) // eslint-disable-line react-hooks/exhaustive-deps
  // If I ignore the exhaustive deps warning and only have requestToShow, it
  // works.  If I have the exhaustive deps added (popper) it causes inf loop
  // due to popper reference changing on every render.

  const styles = { ...popper.styles.popper, zIndex: 10 }
  const classNames = ['c-tooltip', 'c-concept-tooltip']
  if (!show) {
    classNames.push('tw-opacity-0')
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
      onFocus={() => {
        dispatchShow({ focus: true })
      }}
      onBlur={() => {
        dispatchShow({ focus: false })
      }}
      onMouseEnter={() => dispatchShow({ hover: true })}
      onMouseLeave={() => dispatchShow({ hover: false })}
      dangerouslySetInnerHTML={{ __html: html_content }}
    ></div>
  )
}
