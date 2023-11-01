import React from 'react'
import SolutionInfo from './SolutionInfo'
import { FilePanel } from '@/components/mentoring/session/FilePanel'
import { CloseButton } from '@/components/mentoring/session/CloseButton'
import type { CommunitySolution } from '@/components/types'

export type PanesProps = {
  solution: CommunitySolution
}

export function LeftPane({ solution }: PanesProps): JSX.Element {
  return (
    <>
      <header className="discussion-header">
        <CloseButton url="#" />
        <SolutionInfo exercise={solution.exercise} track={solution.track} />
      </header>
      {/* <FilePanel
        files={solution.files}
        language={'ruby'}
        indentSize={2}
      /> */}
    </>
  )
}
