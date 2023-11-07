import React, { useState } from 'react'
import { RecordRow } from './analyzer-tags/RecordRow'
import { FirstRow } from './analyzer-tags/FirstRow'
import type {
  AnalyzerTagsType,
  Links,
} from './analyzer-tags/AnalyzerTags.types'

const statusMockData: AnalyzerTagsType = {
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

export function AnalyzerTags({
  buildStatus = statusMockData,
  links,
}: {
  buildStatus: AnalyzerTagsType
  links?: Links
}): JSX.Element {
  const [status, setStatus] = useState(buildStatus)
  const [editMode, setEditMode] = useState(false)

  return (
    <>
      <FirstRow />
      {status.tags.tags.map((tag, index) => (
        <RecordRow editMode={editMode} status={status} tag={tag} key={index} />
      ))}
      <button
        onClick={() => setEditMode((e) => !e)}
        className="btn-s btn-secondary w-100 mt-24"
      >
        Toggle Edit Mode
      </button>
    </>
  )
}
