import React from 'react'
import {
  CommunitySolution as CommunitySolutionProps,
  Iteration,
} from '../types'
import { CommunitySolution } from '../common'
import { PublishSettings } from './published-solution/PublishSettings'

export type Links = {
  changeIteration: string
  unpublish: string
}

export const PublishedSolution = ({
  publishedIterationIdx,
  iterations,
  solution,
  links,
}: {
  publishedIterationIdx: number | null
  solution: CommunitySolutionProps
  iterations: readonly Iteration[]
  links: Links
}): JSX.Element => {
  return (
    <div>
      <CommunitySolution solution={solution} context="exercise" />
      <PublishSettings
        publishedIterationIdx={publishedIterationIdx}
        iterations={iterations}
        links={links}
      />
    </div>
  )
}
