import React from 'react'
import type { AnalyzerTagsType, Tag } from './AnalyzerTags.types'
import { TagTogglerButton } from './TagTogglerButton'
import { capitalize } from '@/utils/capitalize'

export function RecordRow({
  status,
  tag,
  editMode,
}: {
  status: AnalyzerTagsType
  tag: Tag
  editMode: boolean
}) {
  return (
    <div className="record-row">
      <div className="record-name">
        {tag.tag
          .split(':')
          .map((part) => capitalize(part))
          .join(' → ')}
      </div>
      <div className="record-value dynamic">
        <div className="record-element">
          <strong>{tag.tag}</strong>
        </div>
        <div className="record-element justify-end">
          <TagTogglerButton
            isActive={tag.enabled}
            onClick={() => console.log('clicked')}
            readOnly={!editMode}
          />
        </div>
        <div className="record-element justify-end">
          <TagTogglerButton
            isActive={tag.filterable}
            onClick={() => console.log('something')}
            readOnly={!editMode}
          />
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
