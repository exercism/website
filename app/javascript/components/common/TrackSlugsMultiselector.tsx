import React, { useEffect, useRef } from 'react'
import CreatableSelect from 'react-select/creatable'

export default function TrackSlugsMultiselector({
  trackSlugs,
  selectedTrackSlugs,
}: {
  trackSlugs: string[]
  selectedTrackSlugs: string[]
}): JSX.Element {
  const trackSlugsHiddenInputRef = useRef<HTMLInputElement | null>(null)

  useEffect(() => {
    trackSlugsHiddenInputRef.current = document.querySelector(
      '#partner_advert_track_slugs'
    ) as HTMLInputElement

    if (trackSlugsHiddenInputRef.current) {
      trackSlugsHiddenInputRef.current.value =
        JSON.stringify(selectedTrackSlugs)
    }
  }, [selectedTrackSlugs])

  return (
    <CreatableSelect
      isMulti
      defaultValue={formatTags(selectedTrackSlugs)}
      options={formatTags(trackSlugs)}
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
          '&:focus': {
            border: 'none',
            outline: 'none',
          },
        }),
        indicatorsContainer: (base) => ({
          ...base,
          display: 'none',
          border: 'none',
          '&:focus': {
            border: 'none',
            outline: 'none',
          },
        }),
        input: (base) => ({
          ...base,
          border: 'none',
          outline: 'none',
          boxShadow: 'none',
          '&.c-faux-input': {
            boxShadow: 'none',
          },
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
      onChange={(selected): void => {
        if (trackSlugsHiddenInputRef.current) {
          trackSlugsHiddenInputRef.current.value = JSON.stringify(
            selected.map((s) => s.value)
          )
        }
      }}
    />
  )
}

function formatTags(tags: string[]) {
  return tags.map((tag) => ({
    label: tag,
    value: tag,
  }))
}
