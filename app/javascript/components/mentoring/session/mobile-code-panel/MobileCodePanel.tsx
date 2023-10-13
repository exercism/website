import { Tab } from '@/components/common'
import React from 'react'
import { SessionProps, TabsContext } from '../../Session'
import { Iteration } from '@/components/types'
import { MobileIterationView } from './MobileIterationView'

type MobileCodePanelProps = Pick<
  SessionProps,
  | 'discussion'
  | 'downloadCommand'
  | 'links'
  | 'student'
  | 'exercise'
  | 'track'
  | 'iterations'
  | 'outOfDate'
  | 'instructions'
  | 'testFiles'
> & {
  isLinked: boolean
  setIsLinked: (linked: boolean) => void
  session: SessionProps
  setSession: (session: SessionProps) => void
  currentIteration: Iteration
  onClick: (iteration: Iteration) => void
}
export function MobileCodePanel({
  discussion,
  links,
  student,
  track,
  exercise,
  iterations,
  instructions,
  testFiles,
  outOfDate,
  session,
  setSession,
  onClick,
  currentIteration,
  isLinked,
  setIsLinked,
}: MobileCodePanelProps): JSX.Element {
  return (
    <Tab.Panel id="code" context={TabsContext}>
      <MobileIterationView
        links={links}
        iterations={iterations}
        instructions={instructions}
        testFiles={testFiles}
        currentIteration={currentIteration}
        onClick={onClick}
        isOutOfDate={outOfDate}
        language={track.highlightjsLanguage}
        indentSize={track.indentSize}
        isLinked={isLinked}
        setIsLinked={setIsLinked}
        discussion={discussion}
        exercise={exercise}
        session={session}
        setSession={setSession}
        student={student}
        track={track}
      />
    </Tab.Panel>
  )
}
