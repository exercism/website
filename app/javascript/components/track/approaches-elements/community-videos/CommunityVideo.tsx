import React, { useState } from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { CommunityVideo } from './types'
import { CommunityVideoModal } from './CommunityVideoModal'

export function CommunityVideo({
  video,
}: {
  video: CommunityVideo
}): JSX.Element {
  const [isOpen, setIsOpen] = useState(false)

  return (
    <div className="flex">
      <button
        onClick={() => setIsOpen(true)}
        className="flex items-center justify-between bg-white shadow-sm rounded-8 px-20 py-16 mb-16 grow"
      >
        <div className="flex items-center">
          <img
            style={{ objectFit: 'cover', height: '80px', width: '143px' }}
            className="mr-20 rounded-8"
            src={video.links.thumbnail}
            alt="thumbnail"
          />
          <div className="flex flex-col">
            <h5 className="text-h5 mb-8">{video.title}</h5>
            <div className="flex flex-row items-center">
              <GraphicalIcon
                height={24}
                width={24}
                icon="avatar-placeholder"
                className="mr-8"
              />
              <span className="font-semibold text-textColor6 leading-150 text-14">
                {video.author && video.author.name}
              </span>
            </div>
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
