import React from 'react'
import { useHighlighting } from '@/hooks'
import { SectionHeader } from '.'
import { ConceptMakersButton } from '../ConceptMakersButton'
import { solution } from './mock-snippet'
import { GraphicalIcon, Icon } from '@/components/common'

export function ApproachExamples(): JSX.Element {
  return (
    <div className="flex flex-col">
      <SectionHeader
        title="Approaches"
        description="Other ways our community solved this exercise"
        icon="dig-deeper-gradient"
        className="mb-16"
      />

      <NoApproachYet />
      <Approach />
      <Approach />
      <Approach />
    </div>
  )
}

function Approach(): JSX.Element {
  const codeBlockRef = useHighlighting<HTMLPreElement>()

  return (
    <div className="bg-white shadow-base rounded-8 px-20 py-16 mb-16">
      <pre
        className="border-1 border-lightGray rounded-8 p-16 mb-16"
        ref={codeBlockRef}
      >
        <code
          className={`${solution.track.highlightjsLanguage} block h-[134px] overflow-hidden `}
          style={{ textOverflow: 'ellipsis' }}
        >
          {solution.snippet}
        </code>
      </pre>
      <h5 className="text-h5 mb-2">Using Forwardable</h5>
      <p className="text-p-base text-textColor6 mb-12">
        Explore how to use the Forwardable module and its def_delegator and
        def_delegators methods to use delegation to solve Bob
      </p>
      <ConceptMakersButton
        links={{ makers: 'exercism.org' }}
        numAuthors={5}
        numContributors={3}
        avatarUrls={new Array(3).fill(
          'https://avatars.githubusercontent.com/u/135246?v=4'
        )}
      />
    </div>
  )
}

function NoApproachYet(): JSX.Element {
  return (
    <div className="text-textColor6 flex flex-col items-center bg-bgGray p-24 rounded-8">
      <GraphicalIcon
        icon="sad-exercism"
        height={48}
        width={48}
        className="filter-textColor6 mb-8"
      />
      <div className="text-label-timestamp text-16 mb-4 font-semibold text-center">
        There are no Approaches for Asteroid Space Exploration.
      </div>
      <div className="flex flex-row text-15 leading-150">
        Got one in mind?&nbsp;
        <a className="flex">
          <span className="underline">Post it here.</span>&nbsp;
          <Icon
            className="filter-textColor6"
            icon={'new-tab'}
            alt={'open in a new tab'}
          />
        </a>
      </div>
    </div>
  )
}
