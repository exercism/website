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
