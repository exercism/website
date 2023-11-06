import React from 'react'
import type { TrackStatusTagsType, Tag } from './TrackStatusTags.types'
import { TagTogglerButton } from './TagTogglerButton'

export function RecordRow({
  status,
  tag,
  editMode,
}: {
  status: TrackStatusTagsType
  tag: Tag
  editMode: boolean
}) {
  return (
    <div className="record-row">
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
          {editMode ? (
            <TagTogglerButton
              isActive={tag.enabled}
              onClick={() => console.log('clicked')}
            />
          ) : (
            <strong>{tag.enabled ? 'Yes' : 'No'}</strong>
          )}
        </div>
        <div className="record-element justify-end">
          {editMode ? (
            <TagTogglerButton
              isActive={tag.filterable}
              onClick={() => console.log('something')}
            />
          ) : (
            <strong>{tag.filterable ? 'Yes' : 'No'}</strong>
          )}
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
  )
}
