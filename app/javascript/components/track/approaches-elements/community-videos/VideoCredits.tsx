import { GraphicalIcon, Icon } from '@/components/common'
import React from 'react'
import { CommunityVideo } from './types'

export function VideoCredits({
  author,
}: Pick<CommunityVideo, 'author'>): JSX.Element {
  return (
    <div className="mb-24 py-16 px-32 text-textColor6 flex justify-between items-center border-1 border-borderLight2 rounded-16 shadow-sm">
      {/* <Avatar/> */}
      <div className="grid grid-rows-[24px_24px] grid-cols-[48px_auto] place-items-start gap-x-16">
        <GraphicalIcon
          className="row-span-2 col-span-1"
          icon={'avatar-placeholder'}
          height={48}
          width={48}
        />
        <div className="font-semibold text-textColor1 text-18 leading-160 col-span-1 row-span-2 self-center">
          {author && author.name}{' '}
          <span className="text-14 text-textColor6">
            @{author && author.handle}
          </span>
        </div>
        {/* <div className="text-18 row-span-1 col-span-1 self-center">
          405 subscribers
        </div> */}
      </div>

      <div className="underline font-semibold leading-150 text-14 flex items-center">
        {author && author.links.profile && (
          <a href={author.links.profile} className="mr-32">
            Exercism Profile
          </a>
        )}

        {author && author.links.channel_url && (
          <a
            href={author.links.channel_url}
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
