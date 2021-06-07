import React, { useEffect } from 'react'
import initWalkthrough from '@exercism/twine2-story-format/src/index'

export const Walkthrough = ({ html }: { html: string }): JSX.Element => {
  useEffect(() => {
    initWalkthrough
  }, [])

  return <div dangerouslySetInnerHTML={{ __html: html }} />
}
