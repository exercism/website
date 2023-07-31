import React from 'react'
import dayjs from 'dayjs'
import { Modal } from '@/components/modals'
import type { CommunityVideoType } from '@/components/types'
import { VideoCredits } from './VideoCredits'

export function CommunityVideoModal({
  isOpen,
  onClose,
  video,
}: {
  isOpen: boolean
  onClose: () => void
  video: CommunityVideoType
}): JSX.Element {
  return (
    <Modal
      open={isOpen}
      closeButton
      onClose={onClose}
      className="items-center"
      ReactModalClassName="max-w-[800px] p-0"
    >
      <h2 className="md:text-h2 text-h5 mb-24 text-center">{video.title}</h2>
      {/* reponsive top-padding for 16:9 videos */}
      <div
        className="relative overflow-hidden pb-[56.25%] mb-24"
        style={{ width: '100%' }}
      >
        <iframe
          src={video.links.embed}
          frameBorder="0"
          className="rounded-16 mx-auto absolute top-0 bottom-0 left-0 right-0"
          style={{ width: '100%', height: '100%' }}
        ></iframe>
      </div>

      {video.author && (
        <VideoCredits links={video.links} author={video.author} />
      )}
      <div className="text-center text-textColor6 leading-160 text-16">
        Posted by{' '}
        {video.submittedBy.links.profile ? (
          <a href={video.submittedBy.links.profile} className="underline">
            @{video.submittedBy.handle}
          </a>
        ) : (
          `@${video.submittedBy.handle}`
        )}{' '}
        &middot; {dayjs(video.createdAt).format('D MMM YYYY')}
      </div>
    </Modal>
  )
}
