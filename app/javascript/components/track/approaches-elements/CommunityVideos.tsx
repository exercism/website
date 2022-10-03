import React from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { SectionHeader } from '.'

export function CommunityVideos(): JSX.Element {
  return (
    <div>
      <SectionHeader
        title="Community Videos"
        description=" Walkthroughs from people using Exercism "
        icon="community-video-gradient"
        className="mb-24"
      />
      <CommunityVideo />
      <CommunityVideo />
      <CommunityVideosFooter />
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

function CommunityVideosFooter() {
  return (
    <footer className="text-p-small text-textColor6">
      Want your video featured here? Submit it here.
    </footer>
  )
}
