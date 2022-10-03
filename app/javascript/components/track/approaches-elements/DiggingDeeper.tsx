import React from 'react'
import { useHighlighting } from '@/hooks'
import { GraphicalIcon, Icon } from '@/components/common'
import { ConceptMakersButton } from '../ConceptMakersButton'
import { solution } from './mock-snippet'

export function DiggingDeeper({ html }: { html: string }): JSX.Element {
  const codeBlockRef = useHighlighting<HTMLPreElement>()

  return (
    <div className="mb-48">
      <section className="shadow-lgZ1 !py-[18px] mb-16 rounded-8 px-20 lg:px-32 py-20 lg:py-24">
        <h2 className="mb-8 text-h2">Digging deeper</h2>
        <div>An exploration of Asteroid Space Exploration in Ruby.</div>

        <pre
          className="md-container bg-bgGray overflow-auto shadow-baseZ1"
          ref={codeBlockRef}
        >
          <code className={solution.track.highlightjsLanguage}>
            {solution.snippet}
          </code>
        </pre>

        <p>
          Duis placerat ac sem in suscipit. Aliquam accumsan nibh vitae ante
          pharetra pretium. Lorem ipsum dolor sit amet, consectetur adipiscing
          elit. Nunc gravida molestie magna, aliquam dapibus tellus luctus id.
          Interdum et malesuada fames ac ante ipsum primis in faucibus. Maecenas
          eu rhoncus libero. Donec vehicula augue ut nunc faucibus, euismod
          venenatis dui egestas. Integer id aliquam dui, ac vulputate dolor. Ut
          fringilla sapien semper elit luctus dignissim.
        </p>
        <div dangerouslySetInnerHTML={{ __html: html }} />
      </section>

      <DiggingDeeperFooter />
    </div>
  )
}

function DiggingDeeperFooter(): JSX.Element {
  return (
    <footer className="flex items-center justify-between text-textColor6">
      <div className="flex items-center">
        <ConceptMakersButton
          links={{ makers: 'exercism.org' }}
          numAuthors={5}
          numContributors={3}
          avatarUrls={new Array(3).fill(
            'https://avatars.githubusercontent.com/u/135246?v=4'
          )}
        />
        <div className="pl-24 ml-24 border-l-1 border-borderLight2 font-medium">
          Last updated 8 October 2020
        </div>
      </div>
      <div className="flex items-center text-black filter-textColor6 leading-160 font-medium">
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
      </div>
    </footer>
  )
}
