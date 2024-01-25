import React, { useState } from 'react'
import { Avatar, Icon } from '@/components/common'
import { CommunityVideoType } from '@/components/types'
import { CommunityVideoModal } from './CommunityVideoModal'

export function CommunityVideo({
  video,
}: {
  video: CommunityVideoType
}): JSX.Element {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div className="flex">
      <button
        onClick={() => setIsOpen(true)}
        className="flex items-center bg-backgroundColorA shadow-sm rounded-8 px-20 py-16 mb-16 grow"
      >
        <img
          style={{ objectFit: 'cover', height: '80px', width: '143px' }}
          className="mr-20 rounded-8"
          src={video.links.thumbnail}
          alt="thumbnail"
        />
        <div className="flex flex-col mr-auto">
          <h5 className="text-h5 mb-8 text-left">{video.title}</h5>
          <div className="flex items-center">
            {video.author && (
              <Avatar
                src={video.author.avatarUrl}
                className="mr-8 h-[24px] w-[24px]"
              />
            )}
            <span className="font-semibold text-textColor6 leading-150 text-14">
              {video.author && video.author.name}
            </span>
          </div>
        </div>

        <Icon
          className="filter-textColor6 h-[24px] w-[24px]"
          icon={'expand'}
          alt={'see video'}
        />
      </button>
      <CommunityVideoModal
        isOpen={isOpen}
        video={video}
        onClose={() => setIsOpen(false)}
      />
    </div>
  )
}

export function CommunityVideosFooter({
  onClick,
}: {
  onClick: () => void
}): JSX.Element {
  return (
    <footer className="text-p-small text-textColor6">
      Want your video featured here?{' '}
      <button onClick={onClick} className="underline">
        Submit it here
      </button>
      .
    </footer>
  )
}
