import React, { useRef, useState, useEffect } from 'react'
import { usePopper } from 'react-popper'
import { useQuery } from 'react-query'
import { Loading } from '../common/Loading'

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

  const [show, setShow] = useState(false)
  const tooltipRef = useRef(null)

  const popper = usePopper(parent, tooltipRef.current, {
    placement: 'bottom',
    modifiers: [{ name: 'offset', options: { offset: [0, 8] } }],
  })

  useEffect(() => {
    if (requestToShow && popper?.update) {
      popper.update()
      setShow(true)
      return
    }

    setShow(false)
  }, [requestToShow]) // eslint-disable-line react-hooks/exhaustive-deps
  // If I ignore the exhaustive deps and only have requestToShow, it works.  If I have
  // the exhaustive deps added (popper) it causes inf loop due to popper reference changing
  // on every render.

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
    ></div>
  )
}
