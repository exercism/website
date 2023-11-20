import React from 'react'
import { TaggerInformation } from './TaggerInformation'
import { TagSelector } from './TagSelector'
import { CodeTaggerProps, Tags } from '../CodeTagger.types'
import { useSelectTag } from './useSelectTag'
import { ErrorBoundary, ErrorMessage } from '@/components/ErrorBoundary'
import { ErrorFallback } from '@/components/common/ErrorFallback'

type RightPaneProps = Pick<CodeTaggerProps, 'links'> &
  Record<'tags' | 'allEnabledTrackTags', Tags>

const defaultError = new Error('Unable to confirm tags')

export function RightPane({
  tags,
  allEnabledTrackTags,
  links,
}: RightPaneProps): JSX.Element {
  const { confirmTags, setSelectedTags, error } = useSelectTag({
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
      <ErrorBoundary
        FallbackComponent={(props) => (
          <ErrorFallback error={props.error} className="mb-12" />
        )}
      >
        <ErrorMessage error={error} defaultError={defaultError} />
      </ErrorBoundary>
    </div>
  )
}
