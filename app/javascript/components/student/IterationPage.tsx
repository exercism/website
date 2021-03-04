import React from 'react'
import { Iteration } from '../types'
import { IterationReport } from './iteration-page/IterationReport'

export type Exercise = {
  title: string
}

export type Track = {
  title: string
  iconUrl: string
  highlightJsLanguage: string
}

export type Links = {
  getMentoring: string
  automatedFeedbackInfo: string
}

export const IterationPage = ({
  iterations,
  exercise,
  track,
  links,
}: {
  iterations: readonly Iteration[]
  exercise: Exercise
  track: Track
  links: Links
}): JSX.Element => {
  return (
    <section className="iterations">
      {iterations.map((iteration, i) => {
        return (
          <IterationReport
            key={i}
            iteration={iteration}
            exercise={exercise}
            track={track}
            links={links}
          />
        )
      })}
    </section>
  )
}
