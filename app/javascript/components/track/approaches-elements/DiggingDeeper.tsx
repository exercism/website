import React from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { ConceptMakersButton } from '../ConceptMakersButton'

export type ApproachIntroduction = {
  html: string
  avatarUrls: string[]
  links: { edit: string }
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
      <section className="shadow-lgZ1 !py-[18px] mb-16 rounded-8 px-20 lg:px-32 py-20 lg:py-24">
        <h2 className="mb-8 text-h2">Digging deeper</h2>
        <div
          className="c-textual-content --small"
          dangerouslySetInnerHTML={{ __html: introduction.html }}
        />
      </section>

      <DiggingDeeperFooter introduction={introduction} />
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
        <ConceptMakersButton
          links={{ makers: 'exercism.org' }}
          numAuthors={introduction.numAuthors}
          numContributors={introduction.numContributors}
          avatarUrls={introduction.avatarUrls}
        />
        <div className="pl-24 ml-24 border-l-1 border-borderLight2 font-medium">
          Last updated 8 October 2020
        </div>
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
