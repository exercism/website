import React from 'react'
import { GraphicalIcon, Icon, Credits } from '@/components/common'
import dayjs from 'dayjs'
import { NoIntroductionYet } from '.'
import { User } from '@/components/types'

export type ApproachIntroduction = {
  html: string
  avatarUrls: string[]
  links: {
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
  return (
    <div className="mb-48">
      {introduction.html.length > 0 ? (
        <>
          <section className="shadow-lgZ1 py-20 mb-16 rounded-8 px-20 lg:px-32 py-20 lg:py-24 bg-white">
            <h2 className="mb-8 text-h2">Dig deeper</h2>
            <div
              className="c-textual-content --small"
              dangerouslySetInnerHTML={{ __html: introduction.html }}
            />
          </section>

          <DiggingDeeperFooter introduction={introduction} />
        </>
      ) : (
        <NoIntroductionYet introduction={introduction} />
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
          className="text-textColor1 font-semibold leading-150"
          // TODO: we will need correct data for users here
          users={introduction.avatarUrls.map((a) => {
            const user: User = {
              avatarUrl: a,
              handle: '',
            }

            return user
          })}
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
