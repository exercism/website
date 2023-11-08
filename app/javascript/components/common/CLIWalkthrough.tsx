import React, { useEffect, useRef } from 'react'
import $ from 'jquery'
import Story from '@exercism/twine2-story-format/src/story'

declare global {
  interface Window {
    story: Story
  }
}

export default ({ html }: { html: string }): JSX.Element => {
  const hasRun = useRef(false)
  const scrollToTop = () => {
    window.scrollTo({ top: 0 })
  }
  useEffect(() => {
    if (!hasRun.current) {
      window.story = new Story($('tw-storydata'))
      window.story.start($('#main'))

      $(window).on('shown.sm.passage', scrollToTop)
    }
    hasRun.current = true

    return () => {
      $(window).off('shown.sm.passage', scrollToTop)
    }
  }, [])

  return (
    <div
      className="c-cli-walkthrough"
      dangerouslySetInnerHTML={{ __html: html }}
    />
  )
}
