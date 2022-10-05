import { Modal } from '@/components/modals'
import dayjs from 'dayjs'
import React from 'react'
import { CommunityVideo } from './types'
import { VideoCredits } from './VideoCredits'

export function CommunityVideoModal({
  isOpen,
  onClose,
  video,
}: {
  isOpen: boolean
  onClose: () => void
  video: CommunityVideo
}): JSX.Element {
  return (
    <Modal open={isOpen} closeButton onClose={onClose} className="items-center">
      <h2 className="text-h2 mb-24 text-center">{video.title}</h2>
      {/* reponsive top-padding for 16:9 videos */}
      <div
        className="relative overflow-hidden pt-[56.25%] mb-24"
        style={{ width: '100%' }}
      >
        <iframe
          src={video.links.embed}
          frameBorder="0"
          className="rounded-16 mx-auto absolute top-0 bottom-0 left-0 right-0"
          style={{ width: '100%', height: '100%' }}
        ></iframe>
      </div>

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
