import React, { useState } from 'react'
import { GraphicalIcon, Icon } from '@/components/common'
import { SectionHeader } from '.'
import { Modal } from '@/components/modals'
import { UploadVideoModal } from '@/components/modals/upload-video'

export function CommunityVideos(): JSX.Element {
  const [isOpen, setIsOpen] = useState(false)
  const [uploadModalOpen, setUploadModalOpen] = useState(false)

  return (
    <div>
      <SectionHeader
        title="Community Videos"
        description=" Walkthroughs from people using Exercism "
        icon="community-video-gradient"
        className="mb-24"
      />
      <CommunityVideo onClick={() => setIsOpen(true)} />
      <CommunityVideo onClick={() => setIsOpen(true)} />
      <CommunityVideosFooter onClick={() => setUploadModalOpen(true)} />

      <CommunityVideoModal isOpen={isOpen} onClose={() => setIsOpen(false)} />
      <UploadVideoModal
        isOpen={uploadModalOpen}
        onClose={() => setUploadModalOpen(false)}
      />
    </div>
  )
}

function CommunityVideo({ onClick }: { onClick: () => void }): JSX.Element {
  return (
    <div className="flex">
      <button
        onClick={onClick}
        className="flex items-center justify-between bg-white shadow-sm rounded-8 px-20 py-16 mb-16 grow"
      >
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
      </button>
    </div>
  )
}

function CommunityVideosFooter({ onClick }: { onClick: () => void }) {
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

function CommunityVideoModal({
  isOpen,
  onClose,
}: {
  isOpen: boolean
  onClose: () => void
}): JSX.Element {
  return (
    <Modal open={isOpen} onClose={onClose} className="items-center">
      <h2 className="text-h2 mb-24 text-center">How I Solved TwoFer in Go!</h2>
      <iframe
        src="https://www.youtube.com/watch?v=3elGSZSWTbM&ab_channel=KevinPowell"
        height={360}
        width={768}
        frameBorder="0"
        className="rounded-16 mb-24"
      ></iframe>

      <VideoCredits />
      <div className="text-center text-textColor6 leading-160 text-16">
        Posted by <span className="underline">@ihid</span> &middot; 25 Sep 2022
      </div>
    </Modal>
  )
}

function VideoCredits(): JSX.Element {
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
        <div className="font-semibold text-textColor1 text-18 leading-160 col-span-1 row-span-1 self-center">
          Mike Zornek <span className="text-14">@mike</span>
        </div>
        <div className="text-18 row-span-1 col-span-1 self-center">
          405 subscribers
        </div>
      </div>

      <div className="underline font-semibold leading-150 text-14 flex items-center">
        <a href="" className="mr-32">
          Exercism Profile
        </a>
        <a href="" className="flex">
          YouTube Channel&nbsp;
          <Icon
            className="filter-textColor6 ml-12"
            icon={'new-tab'}
            alt={'open in new tab'}
          />
        </a>
      </div>
    </div>
  )
}
