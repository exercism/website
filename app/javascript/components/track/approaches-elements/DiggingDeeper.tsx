import React, { useContext } from 'react'
import { GraphicalIcon, Icon, Credits } from '@/components/common'
import dayjs from 'dayjs'
import { NoIntroductionYet } from './no-content-yet'
import { ApproachesDataContext } from '../Approaches'

export type ApproachIntroduction = {
  html: string
  avatarUrls: string[]
  links: {
    new: string
    edit: string
  }
  numAuthors: number
  numContributors: number
  updatedAt: string
}

export function DiggingDeeper({
  introduction,
}: {
  introduction: ApproachIntroduction
}): JSX.Element {
  const { exercise } = useContext(ApproachesDataContext)
  return (
    <div className="mb-48">
      {introduction.html.length > 0 ? (
        <>
          <section className="shadow-lgZ1 !py-[18px] mb-16 rounded-8 px-20 lg:px-32 py-20 lg:py-24">
            <h2 className="mb-8 text-h2">Dig deeper</h2>
            <div
              className="c-textual-content --small"
              dangerouslySetInnerHTML={{ __html: introduction.html }}
            />
          </section>

          <DiggingDeeperFooter introduction={introduction} />
        </>
      ) : (
        <section className="shadow-lgZ1 !py-[18px] mb-16 rounded-8 px-20 lg:px-32 py-20 lg:py-24">
          <h2 className="mb-8 text-h2">Dig deeper</h2>

          <div className="text-textColor6 text-20 mb-16 font-normal">
            There are no Introduction notes for {exercise.title}.
          </div>
          <div className="flex text-textColor6 text-14">
            Want to contribute?&nbsp;
            <a className="flex" href={introduction.links.new}>
              <span className="underline">You can do it here.</span>&nbsp;
              <Icon
                className="filter-textColor6"
                icon={'new-tab'}
                alt={'open in a new tab'}
              />
            </a>
          </div>
        </section>
      )}
    </div>
  )
}

function DiggingDeeperFooter({
  introduction,
}: {
  introduction: ApproachIntroduction
}): JSX.Element {
  return (
    <footer className="flex items-center justify-between text-textColor6 py-12 mb-48">
      <div className="flex items-center">
        <Credits
          topCount={introduction.numAuthors}
          topLabel="author"
          bottomCount={introduction.numContributors}
          bottomLabel="contributor"
          max={2}
          avatarUrls={introduction.avatarUrls}
        />
        {introduction.updatedAt && (
          <div className="pl-24 ml-24 border-l-1 border-borderLight2 font-medium">
            Last updated {dayjs(introduction.updatedAt).format('D MMM YYYY')}
          </div>
        )}
      </div>
      <a
        href={introduction.links.edit}
        target="_blank"
        rel="noreferrer"
        className="flex items-center text-black filter-textColor6 leading-160 font-medium"
      >
        <GraphicalIcon
          height={24}
          width={24}
          icon="external-site-github"
          className="mr-12"
        />
        Edit via GitHub
        <Icon
          className="action-icon h-[13px] ml-12"
          icon="new-tab"
          alt="The link opens in a new window or tab"
        />
      </a>
    </footer>
  )
}
