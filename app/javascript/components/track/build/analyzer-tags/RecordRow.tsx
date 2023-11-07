import React, { useCallback } from 'react'
import { capitalize } from '@/utils/capitalize'
import { TagTogglerButton } from './TagTogglerButton'
import type { AnalyzerTagsEndpoints, Tag } from './AnalyzerTags.types'
import { useTagToggler } from './useTagToggler'

export function RecordRow({
  tag,
  editMode,
  setLocalTags,
  endpoints,
}: {
  tag: Tag
  editMode: boolean
  setLocalTags: React.Dispatch<React.SetStateAction<Tag[]>>
  endpoints: AnalyzerTagsEndpoints
}) {
  const { handleToggle } = useTagToggler({ endpoints, setLocalTags })

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
            onClick={() => handleToggle(tag, 'enabled')}
            readOnly={!editMode}
          />
        </div>
        <div className="record-element justify-end">
          <TagTogglerButton
            isActive={tag.filterable}
            onClick={() => handleToggle(tag, 'filterable')}
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
