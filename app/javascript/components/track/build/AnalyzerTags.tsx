import React, { useState } from 'react'
import { RecordRow } from './analyzer-tags/RecordRow'
import { FirstRow } from './analyzer-tags/FirstRow'
import type { AnalyzerTagsType } from './analyzer-tags/AnalyzerTags.types'

export function AnalyzerTags({
  tags,
  editor,
  endpoints,
}: AnalyzerTagsType): JSX.Element {
  const [localTags, setLocalTags] = useState(tags)
  const [editMode, setEditMode] = useState(false)

  return (
    <>
      <FirstRow />
      {localTags.map((tag, index) => (
        <RecordRow
          editMode={editMode}
          tag={tag}
          setLocalTags={setLocalTags}
          key={index}
          endpoints={endpoints}
        />
      ))}
      {editor && (
        <button
          onClick={() => setEditMode((e) => !e)}
          className="btn-s btn-secondary w-100 mt-24"
        >
          Toggle Edit Mode
        </button>
      )}
    </>
  )
}
