import React, { useRef, useState, useEffect, useCallback } from 'react'
import { usePopper } from 'react-popper'
import { useQuery } from 'react-query'
import { Loading } from '../common/Loading'

export const Concept = ({
  endpoint,
  parent,
  triggerShow,
}: {
  endpoint: string
  parent: HTMLElement | null
  triggerShow: boolean
}): JSX.Element => {
  const { isLoading, isError, data: html_content } = useQuery(
    'concept-tooltip',
    () => fetch(endpoint).then((res) => res.text())
  ) as { isLoading: boolean; isError: boolean; data: string }

  const tooltipRef = useRef(null)

  const popper = usePopper(parent, tooltipRef.current, {
    modifiers: [{ name: 'offset', options: { offset: [null, 8] } }],
  })

  const [isHover, setIsHover] = useState<boolean>(false)
  const [show, setShow] = useState<boolean>(false)
  const [hideTimeout, setHideTimeout] = useState<undefined | number>(undefined)

  const hideTooltip = useCallback(() => {
    if (hideTimeout) {
      clearTimeout(hideTimeout)
    }

    setHideTimeout(
      setTimeout(() => {
        setShow(false)
      }, 200)
    )
  }, [hideTimeout])

  const showTooltip = useCallback(() => {
    if (hideTimeout) {
      clearTimeout(hideTimeout)
      setHideTimeout(hideTimeout)
    }
    setShow(true)
  }, [hideTimeout])

  useEffect(() => {
    console.log({ hideTooltip, showTooltip, triggerShow })
    if (triggerShow) {
      showTooltip()
      return
    }

    hideTooltip()

    return () => {}
  }, [hideTooltip, showTooltip, triggerShow])

  const styles = { ...popper.styles.popper, zIndex: 10 }
  const classNames = `c-tooltip c-concept-tooltip ${
    !show ? 'tw-opacity-0' : ''
  }`

  // Separate render exists because happy path needs to render
  // 'dangerouslySetInnerHTML' and this does not.
  if (isLoading || isError) {
    return (
      <div
        ref={tooltipRef}
        className={classNames}
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
      className={classNames}
      style={styles}
      {...popper.attributes.popper}
      role="tooltip"
      dangerouslySetInnerHTML={{ __html: html_content }}
      onMouseEnter={() => setIsHover(true)}
      onMouseLeave={() => setIsHover(false)}
    ></div>
  )
}
