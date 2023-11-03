import React from 'react'
import CodeInfo from './CodeInfo'
import { FilePanel } from '@/components/mentoring/session/FilePanel'
import { CloseButton } from '@/components/mentoring/session/CloseButton'
import { CodeTaggerCode } from '../CodeTagger.types'

export function LeftPane({ code }: { code: CodeTaggerCode }): JSX.Element {
  return (
    <>
      <header className="discussion-header">
        <CloseButton url="#" />
        <CodeInfo exercise={code.exercise} track={code.track} />
      </header>
      <FilePanel files={code.files} language={code.language} indentSize={2} />
    </>
  )
}
