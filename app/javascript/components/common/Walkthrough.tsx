import React, { useEffect } from 'react'
import $ from 'jquery'
import initWalkthrough from '@exercism/twine2-story-format/src/index'

export const Walkthrough = ({ html }: { html: string }): JSX.Element => {
  useEffect(() => {
    initWalkthrough

    const scrollToTop = () => {
      window.scrollTo({ top: 0 })
    }

    $(window).on('shown.sm.passage', scrollToTop)

    return () => {
      $(window).off('shown.sm.passage', scrollToTop)
    }
  }, [])

  return <div dangerouslySetInnerHTML={{ __html: html }} />
}
