import { useHighlighting } from '@/hooks'
import React from 'react'
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
    <div className="flex flex-row">
      <LeftSide />
      {/* <RightSide /> */}
    </div>
  )
}

function LeftSide(): JSX.Element {
  return (
    <div className="mr-40 lg-container flex-grow-2">
      <DiggingDeeper />

      <CommunityVideos />
    </div>
  )
}

function RightSide(): JSX.Element {
  return (
    <div className="flex-grow-1">
      <ApproachExamples />
    </div>
  )
}

function DiggingDeeper(): JSX.Element {
  // const codeBlockRef = useHighlighting<HTMLPreElement>()

  return (
    <div className="mb-48">
      <section className="shadow-lgZ1 !py-[18px] mb-16 rounded-8 px-20 lg:px-32 py-20 lg:py-24">
        <h2 className="mb-8 text-h2">Digging deeper</h2>
        {/* below will probably be MD */}
        {/* <div>An exploration of Asteroid Space Exploration in Ruby.</div>

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
      </p> */}
      </section>

      <Authors />
    </div>
  )
}

function Authors(): JSX.Element {
  return (
    // maybe rework this using grid, because this way it looks very bad.
    <div className="flex items-center justify-between text-textColor6">
      <div className="flex items-center">
        <div className="flex mr-24">
          <GraphicalIcon
            height={32}
            width={32}
            icon="avatar-placeholder"
            className="avatars mr-12"
          />
          <div className="flex flex-col leading-150 text-textColor1">
            <span className="font-semibold">3 authors</span>
            <span className="editors">57 editors</span>
          </div>
        </div>
        <div className="pl-24 border-l-1 border-borderLight2 font-medium">
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
    </div>
  )
}

function ApproachExamples(): JSX.Element {
  return (
    <div className="flex flex-col">
      <div className="flex flex-row items-top">
        <GraphicalIcon className="mr-24" icon="dig-deeper" />
        <div>
          <h3 className="text-h3">Approaches</h3>
          <div className="text-p-base">
            Other ways our community solved this exercise
          </div>
        </div>
      </div>

      {/* <Approach /> */}
    </div>
  )
}

function Approach(): JSX.Element {
  const codeBlockRef = useHighlighting<HTMLPreElement>()

  return (
    <div className="">
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

function CommunityVideos(): JSX.Element {
  return (
    <div>
      <div className="flex flex-row mb-24">
        <GraphicalIcon className="mr-24" icon="community-video" />
        <div>
          <h3 className="text-h3">Community Videos</h3>
          <div className="text-p-base">
            Walkthroughs from people using Exercism
          </div>
        </div>
      </div>
      <CommunityVideo />
      <CommunityVideo />

      <CommunityVideoFooter />
    </div>
  )
}

function CommunityVideo(): JSX.Element {
  return (
    <div className="flex items-center justify-between bg-white shadow-sm rounded-8 px-20 py-16 mb-16">
      <div className="flex items-center">
        <img
          style={{ objectFit: 'cover', height: '80px', width: '143px' }}
          className="mr-20 rounded-8"
          src="https://i.ytimg.com/vi/hFZFjoX2cGg/sddefault.jpg"
          alt="thumbnail"
        />
        <div className="flex flex-col">
          <h5 className="text-h5 mb-8">
            Exercism Elixir Track: Community Garden (Agent)
          </h5>
          <div className="flex flex-row items-center">
            <GraphicalIcon
              height={24}
              width={24}
              icon="avatar-placeholder"
              className="mr-8"
            />
            <span className="font-semibold text-textColor6 leading-150 text-14">
              Erik
            </span>
          </div>
        </div>
      </div>

      <Icon
        className="filter-textColor6 h-[24px] w-[24px]"
        icon={'expand'}
        alt={'see video'}
      />
    </div>
  )
}

function CommunityVideoFooter() {
  return (
    <p className="text-p-small text-textColor6">
      Want your video featured here? Submit it here.
    </p>
  )
}
