import React, { useState } from 'react'
import { MentoringPanelList } from './discussion/MentoringPanelList'
import { IterationsList } from './discussion/IterationsList'
import { BackButton } from './discussion/BackButton'
import { SolutionInfo } from './discussion/SolutionInfo'
import { IterationFiles } from './discussion/IterationFiles'

type Links = {
  scratchpad: string
  exercise: string
}

export type Iteration = {
  idx: number
  numComments: number
  unread: boolean
  links: {
    posts: string
    files: string
  }
}

export type Student = {
  avatarUrl: string
  handle: string
}

export type Track = {
  title: string
  iconUrl: string
  slug: string
}

export type Exercise = {
  title: string
}

export const Discussion = ({
  student,
  track,
  exercise,
  links,
  discussionId,
  iterations,
}: {
  student: Student
  track: Track
  exercise: Exercise
  links: Links
  discussionId: number
  iterations: Iteration[]
}): JSX.Element => {
  const [currentIteration, setCurrentIteration] = useState(
    iterations[iterations.length - 1]
  )

  return (
    <div className="c-mentor-discussion">
      <header className="discussion-header">
        <BackButton url={links.exercise} />
        <SolutionInfo student={student} track={track} exercise={exercise} />
        <IterationsList
          iterations={iterations}
          onClick={setCurrentIteration}
          current={currentIteration}
        />
      </header>
      <article>
        <div className="lhs">
          <div className="iteration-content">
            <div className="code">
              <IterationFiles
                endpoint={currentIteration.links.files}
                language={track.slug}
              />
            </div>
          </div>
        </div>
        <div className="rhs">
          <MentoringPanelList
            links={links}
            discussionId={discussionId}
            iteration={currentIteration}
          />
        </div>
      </article>
    </div>
  )
}
