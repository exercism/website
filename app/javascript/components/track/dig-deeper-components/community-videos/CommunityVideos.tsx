// i18n-key-prefix: communityVideos
// i18n-namespace: components/track/dig-deeper-components/community-videos
import React, { useContext, useState } from 'react'
import { UploadVideoModal } from '@/components/modals'
import type { CommunityVideosProps } from '@/components/types'
import { NoContentYet, SectionHeader } from '..'
import { DigDeeperDataContext } from '../../DigDeeper'
import { CommunityVideo, CommunityVideosFooter } from './CommunityVideo'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function CommunityVideos({ videos }: CommunityVideosProps): JSX.Element {
  const [uploadModalOpen, setUploadModalOpen] = useState(false)
  const { t } = useAppTranslation(
    'components/track/dig-deeper-components/community-videos'
  )

  const { exercise } = useContext(DigDeeperDataContext)
  return (
    <div>
      <SectionHeader
        title={t('communityVideos.communityVideos')}
        description={t('communityVideos.walkthroughsFromPeople')}
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
            {t('communityVideos.wantYourVideoFeatured')}&nbsp;
            <button onClick={() => setUploadModalOpen(true)} className="flex">
              <span className="underline">
                {t('communityVideos.submitItHere')}.
              </span>
              &nbsp;
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
