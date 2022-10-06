import React from 'react'
import { Icon } from '@/components/common'
import { Exercise } from '@/components/types'
import { ApproachIntroduction } from '../DiggingDeeper'
import { NoContentYet } from './NoContentYet'

export function NoIntroductionYet({
  exercise,
  introduction,
}: {
  exercise: Exercise
  introduction: ApproachIntroduction
}): JSX.Element {
  return (
    <NoContentYet
      exerciseTitle={exercise.title}
      contentType={'Introduction notes'}
    >
      Want to contribute?&nbsp;
      <a className="flex" href={introduction.links.new}>
        <span className="underline">You can do it here.</span>&nbsp;
        <Icon
          className="filter-textColor6"
          icon={'new-tab'}
          alt={'open in a new tab'}
        />
      </a>
    </NoContentYet>
  )
}
