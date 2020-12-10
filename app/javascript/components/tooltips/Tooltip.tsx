import React, { useEffect, useState } from 'react'
import { usePopper } from 'react-popper'
import { useQuery } from 'react-query'
import { useStatefulTooltip } from '../../hooks/use-stateful-tooltip'

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
  }, [dispatch, hoverRequestToShow, id])

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
  }, [dispatch, focusRequestToShow, id])

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
