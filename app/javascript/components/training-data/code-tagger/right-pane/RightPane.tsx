import React from 'react'
import { PlaceholderStuff } from './PlaceholderStuff'
import { TagSelector } from './TagSelector'
import { CodeTaggerProps, Tags } from '../CodeTagger.types'
import { useSelectTag } from './useSelectTag'

type RightPaneProps = Pick<CodeTaggerProps, 'links'> &
  Record<'tags' | 'allEnabledTrackTags', Tags>

export function RightPane({
  tags,
  allEnabledTrackTags,
  links,
}: RightPaneProps): JSX.Element {
  const { confirmTags, setSelectedTags } = useSelectTag({
    links,
    defaultSelectedTags: tags,
  })

  return (
    <div className="px-24 h-100 flex flex-col">
      <PlaceholderStuff />
      <TagSelector
        tags={tags || []}
        allEnabledTrackTags={allEnabledTrackTags || []}
        setSelectedTags={setSelectedTags}
      />
      <button
        onClick={() => confirmTags()}
        className="btn-m btn-primary mb-32 mt-auto"
      >
        Save and tag another…
      </button>
    </div>
  )
}
