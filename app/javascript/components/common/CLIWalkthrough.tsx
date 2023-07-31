import React, { useEffect } from 'react'
import $ from 'jquery'
import Story from '@exercism/twine2-story-format/src/story'

declare global {
  interface Window {
    story: Story
  }
}

export default ({ html }: { html: string }): JSX.Element => {
  useEffect(() => {
    window.story = new Story($('tw-storydata'))
    window.story.start($('#main'))

    const scrollToTop = () => {
      window.scrollTo({ top: 0 })
    }

    $(window).on('shown.sm.passage', scrollToTop)

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
