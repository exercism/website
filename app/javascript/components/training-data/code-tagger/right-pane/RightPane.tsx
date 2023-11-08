import React from 'react'
import { PlaceholderStuff } from './PlaceholderStuff'
import { TagSelector } from './TagSelector'
import { CodeTaggerProps } from '../CodeTagger.types'
import { useSelectTag } from './useSelectTag'

export function RightPane({
  tags,
  allTags,
  links,
}: Pick<CodeTaggerProps, 'tags' | 'links' | 'allTags'>): JSX.Element {
  const { confirmTags, setSelectedTags } = useSelectTag({ links })

  return (
    <div className="px-24 h-100 flex flex-col">
      <PlaceholderStuff />
      <TagSelector tags={allTags || []} setSelectedTags={setSelectedTags} />
      <button
        onClick={() => confirmTags()}
        className="btn-m btn-primary mt-auto mb-64"
      >
        Save and tag another…
      </button>
    </div>
  )
}
