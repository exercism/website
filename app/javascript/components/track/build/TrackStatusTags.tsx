import React, { useState } from 'react'
import { GraphicalIcon } from '@/components/common'
import { RecordRow } from './track-status-tags/RecordRow'
import { FirstRow } from './track-status-tags/FirstRow'
import { TrackHeader } from './track-status-tags/TrackHeader'
import type {
  Links,
  TrackStatusTagsType,
} from './track-status-tags/TrackStatusTags.types'

const statusMockData: TrackStatusTagsType = {
  tags: {
    tags: [
      { tag: 'construct:add', enabled: true, filterable: true },
      { tag: 'construct:multiply', enabled: true, filterable: true },
    ],
    solutionCounts: {
      'construct:add': 23,
      'construct:multiply': 252,
    },
  },
}

export function TrackStatusTags({
  buildStatus = statusMockData,
  links,
}: {
  buildStatus: TrackStatusTagsType
  links?: Links
}): JSX.Element {
  const [status, setStatus] = useState(buildStatus)
  const [editMode, setEditMode] = useState(false)

  return (
    <div className="track-team-group">
      <TrackHeader links={links} />
      <details>
        <summary>
          {status.tags.tags.length} tags
          <GraphicalIcon icon="chevron-right" className="summary-chevron" />
        </summary>
        <FirstRow />
        {status.tags.tags.map((tag, index) => (
          <RecordRow
            editMode={editMode}
            status={status}
            tag={tag}
            key={index}
          />
        ))}
        <button
          onClick={() => setEditMode((e) => !e)}
          className="btn-m btn-primary"
        >
          Edit
        </button>
      </details>
    </div>
  )
}
