import React from 'react'
import { capitalize } from '@/utils/capitalize'
import { TagTogglerButton } from './TagTogglerButton'
import type { Tag } from './AnalyzerTags.types'

export function RecordRow({ tag, editMode }: { tag: Tag; editMode: boolean }) {
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
          <strong>{tag.numSolution.toLocaleString()}</strong>
        </div>
      </div>
    </div>
  )
}
