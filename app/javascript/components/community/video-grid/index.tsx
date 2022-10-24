import React, { useState } from 'react'
import { QueryStatus } from 'react-query'
import { CommunityVideoModal } from '@/components/track/approaches-elements/community-videos/CommunityVideoModal'
import { VideoTrack } from '@/components/types'
import { Request } from '@/hooks/request-query'
import { Avatar, GraphicalIcon, Pagination } from '../../common'
import { TrackFilterList } from './TrackFilterList'
import { HandleTrackChangeType, useVideoGrid, VideoData } from './useVideoGrid'

type VideoGridProps = {
  data: {
    tracks: VideoTrack[]
    request: Request
    selectedTrackSlug: string | null
  }
}

export function VideoGrid({ data }: VideoGridProps): JSX.Element {
  const {
    resolvedData,
    page,
    setPage,
    handleTrackChange,
    selectedTrack,
    criteria,
    setCriteria,
  } = useVideoGrid(data.request, data.tracks, data.selectedTrackSlug)

  return (
    <div className="p-40 bg-white shadow-lgZ1 rounded-16 mb-64">
      <VideoGridHeader
        tracks={data.tracks}
        handleTrackChange={handleTrackChange}
        selectedTrack={selectedTrack}
      />

      <div className="flex mb-32 c-search-bar">
        <input
          className="grow --search --right"
          placeholder="Search community walkthroughs"
          value={criteria}
          onChange={(e) => setCriteria(e.target.value)}
        />
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-16">
        {resolvedData &&
          resolvedData.results &&
          resolvedData.results.map((video: VideoData) => (
            <Video key={video.embedUrl} video={video} />
          ))}
      </div>
      {resolvedData && (
        <Pagination
          current={page}
          total={resolvedData.meta.totalPages}
          setPage={setPage}
        />
      )}
    </div>
  )
}

function VideoGridHeader({
  tracks,
  handleTrackChange,
  selectedTrack,
}: {
  tracks: VideoTrack[]
  handleTrackChange: HandleTrackChangeType
  selectedTrack: VideoTrack
}): JSX.Element {
  return (
    <div className="flex mb-24">
      <GraphicalIcon
        icon="community-video-gradient"
        height={48}
        width={48}
        className="mr-24 self-start"
      />
      <div className="mr-auto">
        <h2 className="text-h2 mb-4">Learn from our community</h2>
        <p className="text-p-large">
          Walkthroughs from our community using Exercism
        </p>
      </div>

      <TrackFilterList
        isFetching={false}
        value={selectedTrack}
        tracks={tracks}
        setValue={handleTrackChange}
        sizeVariant="automation"
        cacheKey={''}
        status={QueryStatus.Success}
        error={undefined}
        countText={'video'}
      />
    </div>
  )
}

type VideoProps = {
  video: VideoData
}
function Video({ video }: VideoProps): JSX.Element {
  const [isOpen, setIsOpen] = useState(false)
  return (
    <>
      <button
        onClick={() => setIsOpen(true)}
        className="grid shadow-smZ1 p-16 bg-white rounded-8 text-left"
      >
        <img
          style={{ objectFit: 'cover', width: '100%', height: '150px' }}
          className="rounded-8 self-center mb-12"
          src={video.thumbnailUrl}
          alt="thumbnail"
        />
        <h5 className="text-h5">{video.title}</h5>
        {video.author && (
          <div className="mt-auto pt-8 flex items-center text-left text-textColor6 font-semibold">
            <Avatar
              className="h-[24px] w-[24px] mr-8"
              src={video.author && video.author.avatarUrl}
            />
            {video.author && video.author.name}
          </div>
        )}
      </button>
      <CommunityVideoModal
        isOpen={isOpen}
        onClose={() => setIsOpen(false)}
        video={{
          author: video.author,
          submittedBy: {
            name: '',
            handle: '',
            avatarUrl: '',
            links: {
              profile: undefined,
              channel_url: undefined,
            },
          },
          platform: 'youtube',
          title: video.title,
          createdAt: '',
          links: {
            watch: '',
            embed: video.embedUrl,
            channel: '',
            thumbnail: '',
          },
        }}
      />
    </>
  )
}
