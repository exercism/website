import React from 'react'
import { TaggerInformation } from './TaggerInformation'
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
      <TaggerInformation />
      <TagSelector
        tags={tags || []}
        allEnabledTrackTags={allEnabledTrackTags || []}
        setSelectedTags={setSelectedTags}
      />
      <button onClick={() => confirmTags()} className="btn-m btn-primary mb-32">
        Save and tag another…
      </button>
    </div>
  )
}
