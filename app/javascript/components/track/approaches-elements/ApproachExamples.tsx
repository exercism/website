import { Icon } from '@/components/common'
import React, { useContext } from 'react'
import { NoContentYet, SectionHeader } from '.'
import { ApproachesDataContext } from '../Approaches'

export function ApproachExamples(): JSX.Element {
  const { exercise } = useContext(ApproachesDataContext)
  return (
    <div className="flex flex-col">
      <SectionHeader
        title="Approaches"
        description="Other ways our community solved this exercise"
        icon="dig-deeper-gradient"
        className="mb-16"
      />

      <NoContentYet exerciseTitle={exercise.title} contentType={'Approaches'}>
        Coming soon!
        {/* Got one in mind?&nbsp;
        <a className="flex">
          <span className="underline">Post it here.</span>&nbsp;
          <Icon
            className="filter-textColor6"
            icon={'new-tab'}
            alt={'open in a new tab'}
          />
        </a> */}
      </NoContentYet>
    </div>
  )
}
