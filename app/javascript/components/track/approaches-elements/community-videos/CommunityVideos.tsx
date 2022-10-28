import React, { useContext, useState } from 'react'
import { UploadVideoModal } from '@/components/modals'
import { NoContentYet, SectionHeader } from '..'
import { DigDeeperDataContext } from '../../DigDeeper'
import { CommunityVideosProps } from './types'
import { CommunityVideo, CommunityVideosFooter } from './CommunityVideo'
import { ApproachesDataContext } from '../../Approaches'
import type { CommunityVideosProps } from '@/components/types'

export function CommunityVideos({ videos }: CommunityVideosProps): JSX.Element {
  const [uploadModalOpen, setUploadModalOpen] = useState(false)

  const { exercise } = useContext(DigDeeperDataContext)
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
