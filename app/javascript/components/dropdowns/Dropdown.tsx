import React, { useEffect, useState } from 'react'
import { usePopper } from 'react-popper'

interface DropdownProps {
  id: string
  className: string
  referenceElement: HTMLElement | null
  htmlContent: string
}

export const Dropdown = ({
  id,
  className,
  referenceElement,
  htmlContent,
}: DropdownProps): JSX.Element | null => {
  const [dropdownElement, setDropdownElement] = useState<HTMLElement | null>(
    null
  )

  // const {
  //   state: { showState },
  //   dispatch,
  //   addOpenTooltip,
  //   removeOpenTooltip,
  //   closeOtherOpenTooltips,
  // } = useStatefulTooltip()

  const popper = usePopper(referenceElement, dropdownElement, {
    placement: 'bottom-end',
    modifiers: [{ name: 'offset', options: { offset: [0, 8] } }], // offset from the tooltip's reference element
  })

  // // useEffect for responding to the reference element's request to show when hovered
  // useEffect(() => {
  //   if (hoverRequestToShow) {
  //     return dispatchRequestShowFromRefHover(dispatch, id)
  //   }

  //   // setTimeout used to fire this dispatch AFTER the tooltip self-hover has time to fire
  //   const timeoutRef = setTimeout(() => {
  //     dispatchRequestHideFromRefHover(dispatch, id)
  //   }, 0)

  //   return () => {
  //     clearTimeout(timeoutRef)
  //   }
  // }, [dispatch, hoverRequestToShow, id])

  // // useEffect for responding to the tooltips internal state
  // useEffect(() => {
  //   if (isError) {
  //     removeOpenTooltip(id)
  //     return dispatchError(dispatch, id)
  //   }

  //   switch (showState) {
  //     case 'loading':
  //       if (isLoading) {
  //         return
  //       }
  //       dispatchLoaded(dispatch, id)
  //       break
  //     case 'invisible':
  //       addOpenTooltip(id, dispatch as React.Dispatch<unknown>)
  //       dispatchShow(dispatch, id)
  //       break
  //     case 'visible':
  //       closeOtherOpenTooltips(id)
  //       break
  //     case 'hidden':
  //       removeOpenTooltip(id)
  //       break
  //   }

  //   return () => removeOpenTooltip(id)
  // }, [
  //   showState,
  //   id,
  //   isLoading,
  //   isError,
  //   dispatch,
  //   removeOpenTooltip,
  //   addOpenTooltip,
  //   closeOtherOpenTooltips,
  // ])

  // // short-circuit return null if not ready to display the tooltip
  // if ((showState !== 'visible' && showState !== 'invisible') || !htmlContent) {
  //   return null
  // }

  // Get styles and classes to apply
  const styles = { ...popper.styles.popper, zIndex: 10 }
  const classNames = ['c-tooltip', className]
  // if (showState === 'invisible') {
  //   classNames.push('tw-invisible')
  // }
  // if (showState === 'visible') {
  //   classNames.push('tw-pointer-events-auto')
  // }

  return (
    <div
      ref={setDropdownElement}
      className={classNames.join(' ')}
      style={styles}
      {...popper.attributes.popper}
      role="dropdown"
      // tabIndex={showState === 'visible' ? undefined : -1}
      // onFocus={() => dispatchRequestShowFromFocus(dispatch, id)}
      dangerouslySetInnerHTML={{ __html: htmlContent }}
    ></div>
  )
}
