import React from 'react'
import { Avatar, Icon } from '@/components/common'
import type { CommunityVideoType } from '@/components/types'

export function VideoCredits({
  author,
  links,
}: Pick<CommunityVideoType, 'author' | 'links'>): JSX.Element {
  return (
    <div className="mb-24 py-16 px-32 text-textColor6 flex justify-between items-center border-1 border-borderLight2 rounded-16 shadow-sm md:flex-row flex-col">
      <div className="grid grid-rows-[24px_24px] grid-cols-[48px_auto] place-items-start gap-x-16">
        {author && (
          <Avatar
            className="row-span-2 col-span-1 h-[48px] w-[48px]"
            src={author.avatarUrl}
          />
        )}
        {author && (
          <div className="font-semibold text-textColor1 text-18 leading-160 col-span-1 row-span-2 self-center whitespace-nowrap">
            {author.name}&nbsp;
            <span className="text-14 text-textColor6">@{author.handle}</span>
          </div>
        )}
        {/* <div className="text-18 row-span-1 col-span-1 self-center">
          405 subscribers
        </div> */}
      </div>

      <div className="underline font-semibold leading-150 text-14 flex items-center mt-8 md:mt-0">
        {author && author.links.profile && (
          <a href={author.links.profile} className="mr-32">
            Exercism Profile
          </a>
        )}

        {links.channel.length > 0 && (
          <a
            href={links.channel}
            target="_blank"
            rel="noreferrer"
            className="flex"
          >
            YouTube Channel&nbsp;
            <Icon
              className="filter-textColor6 ml-12"
              icon={'new-tab'}
              alt={'open in new tab'}
            />
          </a>
        )}
      </div>
    </div>
  )
}
