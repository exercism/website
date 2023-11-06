import React from 'react'
import CodeInfo from './CodeInfo'
import { FilePanel } from '@/components/mentoring/session/FilePanel'
import { CloseButton } from '@/components/mentoring/session/CloseButton'
import { CodeTaggerProps } from '../CodeTagger.types'
import { ResultsZone } from '@/components/ResultsZone'

export function LeftPane({
  code,
  links,
}: Pick<CodeTaggerProps, 'code' | 'links'>): JSX.Element {
  return (
    <>
      <header className="discussion-header">
        <CloseButton url={links.trainingDataDashboard} />
        <CodeInfo exercise={code.exercise} track={code.track} />
      </header>
      <ResultsZone isFetching={false}>
        <FilePanel
          files={code.files}
          language={code.track.highlightjsLanguage}
          indentSize={2}
        />
      </ResultsZone>
    </>
  )
}
