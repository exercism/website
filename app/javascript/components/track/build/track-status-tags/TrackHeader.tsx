import React from 'react'
import { Links } from './TrackStatusTags.types'

export function TrackHeader({ links }: { links?: Links }): JSX.Element {
  return (
    <div className="track-header mb-16">
      <div className="flex md:flex-row flex-col md:items-center items-left justify-between mb-8 md:gap-0 gap-y-8">
        <h3 className="--syllabus-gradient">Programming Tags</h3>
        <a
          href={links?.docsBuildingToolingAnalyzersTagsLink}
          className="learn-more-new-tab"
        >
          Learn More
        </a>
      </div>
      <p>
        Help manage the tags used to group, filter and recommend solutions,
        approaches and articles.
      </p>
    </div>
  )
}
