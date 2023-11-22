import React from 'react'
import CreatableSelect from 'react-select/creatable'
import { Tags } from '../CodeTagger.types'

export function TagSelector({
  tags,
  allEnabledTrackTags,
  setSelectedTags,
}: {
  tags: Tags
  allEnabledTrackTags: Tags
  setSelectedTags: React.Dispatch<React.SetStateAction<Tags>>
}): JSX.Element | null {
  if (!tags) return null
  return (
    <CreatableSelect
      className="creatable-select-component text-p-base mt-auto mb-20"
      isMulti
      defaultValue={formatTags(tags)}
      options={formatTags(allEnabledTrackTags)}
      isClearable={false}
      maxMenuHeight={100}
      styles={{
        valueContainer: (base) => ({
          ...base,
          padding: '8px',
        }),

        indicatorSeparator: (base) => ({
          ...base,
          display: 'none',
        }),
        indicatorsContainer: (base) => ({
          ...base,
          display: 'none',
        }),

        multiValue: (base) => ({
          ...base,
          borderRadius: '8px',
          overflow: 'hidden',
          backgroundColor: 'var(--backgroundColorI)',
          border: '1px solid',
          borderColor: '#2E57E8',
          margin: '4px',
        }),
        multiValueLabel: (base) => ({
          ...base,
          fontSize: '16px',
          padding: '4px',
          paddingLeft: '8px',
        }),
        multiValueRemove: (base) => ({
          ...base,
          paddingRight: '8px',
          color: 'var(--textColor6)',
          '&:hover': {
            background: '#E27979',
            color: 'var(--textColor1)',
          },
        }),
      }}
      onChange={(selected): void =>
        setSelectedTags(selected.map((s) => s.label))
      }
    />
  )
}

function formatTags(tags: Tags) {
  return tags.map((tag) => ({
    label: tag,
    value: tag,
  }))
}
