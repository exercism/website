import React from 'react'
import SolutionInfo from './SolutionInfo'
import { FilePanel } from '@/components/mentoring/session/FilePanel'
import { CloseButton } from '@/components/mentoring/session/CloseButton'
import type { CommunitySolution } from '@/components/types'
import { SolutionTaggerSolution } from '../SolutionTagger.types'

export type PanesProps = {
  solution: CommunitySolution
}

export function LeftPane({
  solution,
}: {
  solution: SolutionTaggerSolution
}): JSX.Element {
  return (
    <>
      <header className="discussion-header">
        <CloseButton url="#" />
        <SolutionInfo exercise={solution.exercise} track={solution.track} />
      </header>
      <FilePanel
        files={solution.files}
        language={solution.language}
        indentSize={2}
      />
    </>
  )
}
