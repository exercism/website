import React, { useEffect, useRef } from 'react'
import { SelectInstance, GroupBase } from 'react-select'
import CreatableSelect from 'react-select/creatable'

type OptionType = {
  label: string
  value: string
}

export default function TrackSlugsMultiselector({
  trackSlugs,
  selectedTrackSlugs,
}: {
  trackSlugs: string[]
  selectedTrackSlugs: string // comes as a JSON array
}): JSX.Element {
  const trackSlugsHiddenInputRef = useRef<HTMLInputElement | null>(null)
  const selectRef =
    useRef<SelectInstance<OptionType, true, GroupBase<OptionType>>>(null)

  useEffect(() => {
    trackSlugsHiddenInputRef.current = document.querySelector(
      '#partner_advert_track_slugs'
    ) as HTMLInputElement

    if (trackSlugsHiddenInputRef.current) {
      trackSlugsHiddenInputRef.current.value =
        JSON.stringify(selectedTrackSlugs)
    }
  }, [selectedTrackSlugs])

  // Removes the annoying blue box-shadow on the embedded input
  const handleFocus = () => {
    if (selectRef.current) {
      const input = selectRef.current.inputRef

      if (input) {
        input.style.boxShadow = 'none'
      }
    }
  }

  return (
    <CreatableSelect
      isMulti
      ref={selectRef}
      defaultValue={formatTags(JSON.parse(selectedTrackSlugs))}
      options={formatTags(trackSlugs)}
      isClearable={false}
      maxMenuHeight={100}
      onFocus={handleFocus}
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
