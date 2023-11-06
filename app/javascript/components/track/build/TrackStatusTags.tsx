import React from 'react'
import { GraphicalIcon } from '@/components/common'

const status = {
  tags: {
    tags: [
      { tag: 'construct:add', enabled: true, filterable: true },
      { tag: 'construct:multiply', enabled: true, filterable: true },
    ],
    solutionCounts: {
      'construct:add': 23,
      'construct:nultiply': 252,
    },
  },
}

export function TrackStatusTags(): JSX.Element {
  return (
    <div className="track-team-group">
      <div className="track-header mb-16">
        <div className="flex md:flex-row flex-col md:items-center items-left justify-between mb-8 md:gap-0 gap-y-8">
          <h3 className="--syllabus-gradient">Programming Tags</h3>
          <a
            href="/docs/building/tooling/analyzers/tags"
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

      <details>
        <summary>
          {status.tags.tags.length} tags
          <GraphicalIcon icon="chevron-right" className="summary-chevron" />
        </summary>
        <div className={`record-row sticky z-1 lg:top-0 top-[65px]`}>
          <div className="record-name"></div>
          <div className="record-value">
            <div className="record-element">Tag</div>
            <div className="record-element justify-end">Enabled</div>
            <div className="record-element justify-end">Filterable</div>
            <div className="record-element justify-end">Num Solutions</div>
          </div>
        </div>
        {status.tags.tags.map((tag, index) => (
          <div className="record-row" key={index}>
            <div className="record-name">
              {tag.tag
                .split(':')
                .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
                .join(' → ')}
            </div>
            <div className="record-value">
              <div className="record-element">
                <strong>{tag.tag}</strong>
              </div>
              <div className="record-element justify-end">
                <strong>{tag.enabled ? 'Yes' : 'No'}</strong>
              </div>
              <div className="record-element justify-end">
                <strong>{tag.filterable ? 'Yes' : 'No'}</strong>
              </div>
              <div className="record-element justify-end">
                <strong>
                  {status.tags.solutionCounts[tag.tag]
                    ? status.tags.solutionCounts[tag.tag].toLocaleString()
                    : 0}
                </strong>
              </div>
            </div>
          </div>
        ))}
      </details>
    </div>
  )
}
