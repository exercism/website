import React, { useState } from 'react'
import { QueryStatus } from 'react-query'
import { Avatar, GraphicalIcon, Pagination } from '../../common'
import { TrackFilterList } from './TrackFilterList'

type VideoGridProps = {
  data: any
}

export function VideoGrid({ data }: VideoGridProps): JSX.Element {
  const [page, setPage] = useState<number>(1)

  return (
    <div className="p-40 bg-white shadow-lgZ1 rounded-16 mb-64">
      <VideoGridHeader tracks={data.tracks} />
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-16">
        {new Array(12).fill(
          <Video
            title="Exercism Elixir Track: Community Garden (Agent)"
            author="Bobbi Towers"
            avatarUrl="https://avatars.githubusercontent.com/u/24420806?v=4"
          />
        )}
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

type VideoProps = {
  title: string
  author: string
  avatarUrl: string
}
function Video({ title, author, avatarUrl }: VideoProps): JSX.Element {
  return (
    <button className="grid shadow-sm p-16 bg-white rounded-8 text-left">
      <div className="self-center bg-borderLight rounded-8 mb-12 max-w-[100%] pb-[46.25%]"></div>
      <h5 className="text-h5 mb-8">{title}</h5>
      <div className="flex items-center text-left text-textColor6 font-semibold">
        <Avatar className="h-[24px] w-[24px] mr-8" src={avatarUrl} />
        {author}
      </div>
    </button>
  )
}
