import { CommunityVideoAuthor } from '@/components/track/approaches-elements/community-videos/types'
import React, { useState } from 'react'
import { QueryStatus } from 'react-query'
import { Avatar, GraphicalIcon, Pagination } from '../../common'
import { TrackFilterList } from './TrackFilterList'
import { useVideoGrid } from './useVideoGrid'

type VideoGridProps = {
  data: any
}

export function VideoGrid({ data }: VideoGridProps): JSX.Element {
  const [page, setPage] = useState<number>(1)
  const [criteria, setCriteria] = useState('')

  const { resolvedData } = useVideoGrid(data.request)
  console.log('rd', resolvedData)

  return (
    <div className="p-40 bg-white shadow-lgZ1 rounded-16 mb-64">
      <VideoGridHeader tracks={data.tracks} />

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
          resolvedData.results.map((video: VideoProps) => (
            <Video key={video.embedUrl} video={video} />
          ))}
      </div>
      <Pagination current={page} total={120} setPage={setPage} />
    </div>
  )
}

function VideoGridHeader({ tracks }: { tracks: any }): JSX.Element {
  return (
    <div className="flex mb-24">
      <GraphicalIcon
        icon="community-video-gradient"
        height={48}
        width={48}
        className="mr-24 self-start"
      />
      <div className="grid gap-8 mr-auto">
        <h2 className="text-h2">Learn from our community</h2>
        <p className="text-p-large">
          Walkthroughs from our community using Exercism
        </p>
      </div>

      <TrackFilterList
        isFetching={false}
        value={tracks[0]}
        tracks={tracks}
        setValue={() => console.log('yolo')}
        sizeVariant="automation"
        cacheKey={''}
        status={QueryStatus.Success}
        error={undefined}
        countText={'video'}
      />
    </div>
  )
}

type VideoData = {
  title: string
  author: CommunityVideoAuthor
  embedUrl: string
  thumbnailUrl: string
}
type VideoProps = {
  video: VideoData
}
function Video({ video }: VideoProps): JSX.Element {
  return (
    <button className="grid shadow-sm p-16 bg-white rounded-8 text-left">
      <div className="self-center bg-borderLight rounded-8 mb-12 max-w-[100%] pb-[46.25%]"></div>
      <img
        style={{ objectFit: 'cover', height: '80px', width: '143px' }}
        className="mr-20 rounded-8"
        src={video.links.thumbnail}
        alt="thumbnail"
      />
      <h5 className="text-h5 mb-8">{title}</h5>
      <div className="flex items-center text-left text-textColor6 font-semibold">
        <Avatar
          className="h-[24px] w-[24px] mr-8"
          src={author && author.avatarUrl}
        />
        {author && author.name}
      </div>
    </button>
  )
}
