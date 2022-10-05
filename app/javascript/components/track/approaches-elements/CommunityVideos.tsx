import React, { useContext, useState } from 'react'
import { Modal, UploadVideoModal } from '@/components/modals'
import { GraphicalIcon, Icon } from '@/components/common'
import { NoContentYet, SectionHeader } from '.'
import { ApproachesDataContext } from '../Approaches'
import dayjs from 'dayjs'

export type CommunityVideoUserLinks = {
  profile?: string
  channel_url?: string
}

export type CommunityVideoUser = {
  name: string
  handle: string
  avatarUrl: string
  links: CommunityVideoUserLinks
}

export type CommunityVideoPlatform = 'youtube' | 'vimeo'

export type CommunityVideoLinks = {
  watch: string
  embed: string
  channel: string
  thumbnail: string
}

export type CommunityVideo = {
  author?: CommunityVideoUser
  submittedBy: CommunityVideoUser
  platform: CommunityVideoPlatform
  title: string
  createdAt: string
  links: CommunityVideoLinks
}

export type CommunityVideosProps = {
  videos: CommunityVideo[]
}

export function CommunityVideos({ videos }: CommunityVideosProps): JSX.Element {
  const [uploadModalOpen, setUploadModalOpen] = useState(false)

  const { exercise } = useContext(ApproachesDataContext)
  return (
    <div>
      <SectionHeader
        title="Community Videos"
        description=" Walkthroughs from people using Exercism "
        icon="community-video-gradient"
        className="mb-24"
      />
      {videos.length > 0 ? (
        <>
          {videos.map((video) => (
            <CommunityVideo
              key={video.createdAt + video.submittedBy.handle}
              video={video}
            />
          ))}
          <CommunityVideosFooter onClick={() => setUploadModalOpen(true)} />
        </>
      ) : (
        <div className="flex items-start">
          <NoContentYet
            exerciseTitle={exercise.title}
            contentType="Community Videos"
          >
            Want your video featured here?&nbsp;
            <button onClick={() => setUploadModalOpen(true)} className="flex">
              <span className="underline">Submit it here.</span>&nbsp;
            </button>
          </NoContentYet>
        </div>
      )}

      <UploadVideoModal
        isOpen={uploadModalOpen}
        onClose={() => setUploadModalOpen(false)}
      />
    </div>
  )
}

function CommunityVideo({ video }: { video: CommunityVideo }): JSX.Element {
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
  video,
}: {
  isOpen: boolean
  onClose: () => void
  video: CommunityVideo
}): JSX.Element {
  return (
    <Modal open={isOpen} onClose={onClose} className="items-center">
      <h2 className="text-h2 mb-24 text-center">{video.title}</h2>
      <iframe
        src={video.links.embed}
        height={432}
        width={768}
        frameBorder="0"
        className="rounded-16 mb-24 mx-auto"
      ></iframe>

      <VideoCredits author={video.author} />
      <div className="text-center text-textColor6 leading-160 text-16">
        Posted by{' '}
        <a href={video.submittedBy.links.profile} className="underline">
          @{video.submittedBy.handle}
        </a>{' '}
        &middot; {dayjs(video.createdAt).format('D MMM YYYY')}
      </div>
    </Modal>
  )
}

function VideoCredits({ author }: Pick<CommunityVideo, 'author'>): JSX.Element {
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
          {author && author.name}{' '}
          <span className="text-14">@{author && author.handle}</span>
        </div>
        <div className="text-18 row-span-1 col-span-1 self-center">
          405 subscribers
        </div>
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
