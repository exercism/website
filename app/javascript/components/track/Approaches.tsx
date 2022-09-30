import { useHighlighting } from '@/hooks'
import React, { useState } from 'react'
import { GraphicalIcon, Icon } from '../common'

const solution = {
  snippet: `
    class BeerSong
    def self.recite(start_verse, take_down)
      lower_bound = start_verse - take_down + 1
      start_verse.downto(lower_bound).map { |i| verse(i) }.join("\\n")
    end
  
    def self.verse(number)
      case number
      when 0
        "No more bottles of beer on the wall, no more bottles of beer.\\nGo to the store and buy some more, 99 bottles of beer on the wall.\\n"
      when 1
        "%s bottle of beer on the wall, %s bottle of beer.\\nTake it down and pass it around, no more bottles of beer on the wall.\\n" % [number, number]
      when 2
        "%s bottles of beer on the wall, %s bottles of beer.\\nTake one down and pass it around, %s bottle of beer on the wall.\\n" % [number, number, number - 1]
      else
        "%s bottles of beer on the wall, %s bottles of beer.\\nTake one down and pass it around, %s bottles of beer on the wall.\\n" % [number, number, number - 1]
      end
    end
  end 
    `,
  track: { highlightjsLanguage: 'ruby' },
}

export function Approaches(): JSX.Element {
  return (
    <div className="lg-container flex flex-row">
      <LeftSide />
      <RightSide />
    </div>
  )
}

function LeftSide(): JSX.Element {
  return (
    <div className="mr-40 flex-grow lg:w-arbitrary">
      <DiggingDeeper />
      <Authors />
    </div>
  )
}

function RightSide(): JSX.Element {
  return (
    <div className="flex-shrink-0">
      <ApproachExamples />
    </div>
  )
}

function DiggingDeeper(): JSX.Element {
  const codeBlockRef = useHighlighting<HTMLPreElement>()

  return (
    <section className="instructions c-textual-content --large shadow-lgZ1 !py-[18px] mb-16 rounded-8 px-20 lg:px-32 py-20 lg:py-24">
      <h2 className="mb-8">Digging deeper</h2>
      {/* below will probably be MD */}
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
    </section>
  )
}

function Authors(): JSX.Element {
  return (
    <div className="flex items-center justify-between text-textColor6">
      <div>
        <GraphicalIcon height={32} width={32} icon="avatar-placeholder" />
        <span>3 authors</span>
        <span>57 authors</span>
      </div>
      <div>Last updated 8 October 2020</div>
      <div>
        <GraphicalIcon height={24} width={24} icon={'external-site-github'} />
        Edit via GitHub
        <Icon
          className="action-icon h-[13px]"
          icon="external-link"
          alt="The link opens in a new window or tab"
        />
      </div>
    </div>
  )
}

function ApproachExamples(): JSX.Element {
  return (
    <div className="action-box flex flex-col">
      <div className="flex flex-row items-top">
        <GraphicalIcon className="mr-24" icon="dig-deeper" />
        <div>
          <h3 className="text-h3">Approaches</h3>
          <div className="text-p-base">
            Other ways our community solved this exercise
          </div>
        </div>
      </div>

      <Approach />
    </div>
  )
}

function Approach(): JSX.Element {
  const codeBlockRef = useHighlighting<HTMLPreElement>()

  return (
    <div
      className="c-community-solution block"
      style={{ width: 'calc(100%/3)' }}
    >
      <pre
        // className="border-1 border-borderColor-7 rounded-8"
        ref={codeBlockRef}
      >
        <code
          className={solution.track.highlightjsLanguage}
          // className={`${solution.track.highlightjsLanguage} p-16 block h-[134px] overflow-hidden truncate`}
        >
          {solution.snippet}
        </code>
      </pre>
    </div>
  )
}
