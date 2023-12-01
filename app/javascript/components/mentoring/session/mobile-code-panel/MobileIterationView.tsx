import React from 'react'
import {
  Iteration,
  IterationStatus,
  MentorDiscussion,
  File,
  TestFile,
} from '@/components/types'
import { IterationsList } from '../IterationsList'
import { FilePanel } from '../FilePanel'
import { usePaginatedRequestQuery } from '@/hooks/request-query'
import { FetchingBoundary } from '@/components/FetchingBoundary'
import { ResultsZone } from '@/components/ResultsZone'
import { LinkButton } from '../LinkButton'
import { SessionProps } from '../../Session'
import {
  MobileIterationHeader,
  MobileIterationHeaderProps,
} from './MobileIterationHeader'

const DEFAULT_ERROR = new Error('Unable to load files')

type MobileIterationViewProps = {
  iterations: readonly Iteration[]
  instructions?: string
  testFiles?: readonly TestFile[]
  currentIteration: Iteration
  onClick: (iteration: Iteration) => void
  language: string
  indentSize: number
  isOutOfDate: boolean
  isLinked: boolean
  setIsLinked: (linked: boolean) => void
  discussion: MentorDiscussion
} & Omit<MobileIterationHeaderProps, 'iteration' | 'files'>

export const MobileIterationView = ({
  iterations,
  instructions,
  testFiles,
  currentIteration,
  onClick,
  language,
  indentSize,
  isOutOfDate,
  isLinked,
  setIsLinked,
  discussion,
  links,
  exercise,
  session,
  setSession,
  student,
  track,
}: MobileIterationViewProps): JSX.Element => {
  /* TODO: (required) Don't do this if currentIteration.links.files is null */
  const {
    data: resolvedData,
    error,
    status,
    isFetching,
  } = usePaginatedRequestQuery<{
    files: readonly File[]
  }>([currentIteration.links.files], {
    endpoint: currentIteration.links.files,
    options: {},
  })

  return (
    <React.Fragment>
      <MobileIterationHeader
        iteration={currentIteration}
        isOutOfDate={isOutOfDate}
        files={resolvedData?.files}
        links={links}
        discussion={discussion}
        exercise={exercise}
        session={session}
        setSession={setSession}
        student={student}
        track={track}
      />
      {currentIteration.status == IterationStatus.DELETED ? (
        <div className="deleted">This iteration has been deleted</div>
      ) : (
        <ResultsZone isFetching={isFetching}>
          <FetchingBoundary
            error={error}
            status={status}
            defaultError={DEFAULT_ERROR}
          >
            {resolvedData ? (
              <FilePanel
                files={resolvedData.files}
                language={language}
                indentSize={indentSize}
                instructions={instructions}
                testFiles={testFiles}
              />
            ) : null}
          </FetchingBoundary>
        </ResultsZone>
      )}
      {iterations.length > 1 ? (
        <footer className="c-iterations-footer">
          <IterationsList
            iterations={iterations}
            onClick={onClick}
            current={currentIteration}
          />
          {discussion ? (
            <LinkButton value={isLinked} setValue={setIsLinked} />
          ) : null}
        </footer>
      ) : null}
    </React.Fragment>
  )
}
