import React, { useEffect, useState } from 'react'
import { usePopper } from 'react-popper'
import {
  useStatefulTooltip,
  dispatchError,
  dispatchLoaded,
  dispatchShow,
  // dispatchHide,
  dispatchRequestHideFromRefHover,
  dispatchRequestHideFromRefFocus,
  dispatchRequestShowFromRefHover,
  dispatchRequestShowFromRefFocus,
  dispatchRequestHideFromHover,
  dispatchRequestHideFromFocus,
  dispatchRequestShowFromHover,
  dispatchRequestShowFromFocus,
} from '../../hooks/use-stateful-tooltip'
import { useContentQuery } from '../../hooks/use-content-query'

interface TooltipProps {
  id: string
  className: string
  referenceElement: HTMLElement | null
  contentEndpoint: string
  hoverRequestToShow: boolean
  focusRequestToShow: boolean
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

  const {
    state: { showState },
    dispatch,
    addOpenTooltip,
    removeOpenTooltip,
    closeOtherOpenTooltips,
  } = useStatefulTooltip()

  const popper = usePopper(referenceElement, tooltipElement, {
    placement: 'bottom',
    modifiers: [{ name: 'offset', options: { offset: [0, 8] } }], // offset from the tooltip's reference element
  })

  const { isLoading, isError, htmlContent } = useContentQuery(
    contentEndpoint,
    contentEndpoint,
    showState != 'hidden' && showState != 'error'
  )

  // useEffect for responding to the reference element's request to show when hovered
  useEffect(() => {
    if (hoverRequestToShow) {
      return dispatchRequestShowFromRefHover(dispatch, id)
    }

    // setTimeout used to fire this dispatch AFTER the tooltip self-hover has time to fire
    const timeoutRef = setTimeout(() => {
      dispatchRequestHideFromRefHover(dispatch, id)
    }, 0)

    return () => {
      clearTimeout(timeoutRef)
    }
  }, [dispatch, hoverRequestToShow, id])

  // useEffect for responding to the reference element's request to show when focused
  useEffect(() => {
    if (focusRequestToShow) {
      return dispatchRequestShowFromRefFocus(dispatch, id)
    }

    // setTimeout used to fire this dispatch AFTER the tooltip self-focus has time to fire
    const timeoutRef = setTimeout(() => {
      dispatchRequestHideFromRefFocus(dispatch, id)
    }, 0)

    return () => {
      clearTimeout(timeoutRef)
    }
  }, [dispatch, focusRequestToShow, id])

  // useEffect for responding to the tooltips internal state
  useEffect(() => {
    if (isError) {
      removeOpenTooltip(id)
      return dispatchError(dispatch, id)
    }

    switch (showState) {
      case 'loading':
        if (isLoading) {
          return
        }
        dispatchLoaded(dispatch, id)
        break
      case 'invisible':
        addOpenTooltip(id, dispatch as React.Dispatch<unknown>)
        dispatchShow(dispatch, id)
        break
      case 'visible':
        closeOtherOpenTooltips(id)
        break
      case 'hidden':
        removeOpenTooltip(id)
        break
    }

    return () => removeOpenTooltip(id)
  }, [
    showState,
    id,
    isLoading,
    isError,
    dispatch,
    removeOpenTooltip,
    addOpenTooltip,
    closeOtherOpenTooltips,
  ])

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
      onFocus={() => dispatchRequestShowFromFocus(dispatch, id)}
      onBlur={() => dispatchRequestHideFromFocus(dispatch, id)}
      onMouseEnter={() => dispatchRequestShowFromHover(dispatch, id)}
      onMouseLeave={() => dispatchRequestHideFromHover(dispatch, id)}
      dangerouslySetInnerHTML={{ __html: htmlContent }}
    ></div>
  )
}
