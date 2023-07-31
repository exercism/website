import React, { useContext } from 'react'
import { Icon } from '@/components/common'
import { ApproachIntroduction } from '../DiggingDeeper'
import { DigDeeperDataContext } from '../../DigDeeper'

export function NoIntroductionYet({
  introduction,
}: {
  introduction: ApproachIntroduction
}): JSX.Element {
  const { exercise } = useContext(DigDeeperDataContext)
  return (
    <section className="shadow-lgZ1 mb-16 rounded-8 px-20 lg:px-32 py-20 lg:py-24 bg-backgroundColorA">
      <h2 className="mb-8 text-h2">Dig deeper</h2>

      <div className="text-textColor6 text-20 mb-16 font-normal leading-150">
        There are no Introduction notes for {exercise.title}.
      </div>
      <div className="flex text-textColor6 text-14 leading-140">
        Want to contribute?&nbsp;
        <a className="flex" href={introduction.links.edit}>
          <span className="underline">You can do it here.</span>&nbsp;
          <Icon
            className="filter-textColor6"
            icon={'new-tab'}
            alt={'open in a new tab'}
          />
        </a>
      </div>
    </section>
  )
}
