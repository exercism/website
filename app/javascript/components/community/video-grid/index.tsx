import React, { useCallback, useRef, useState } from 'react'
import { QueryStatus } from 'react-query'
import { ResultsZone } from '@/components/ResultsZone'
import {
  Avatar,
  FilterFallback,
  GraphicalIcon,
  Pagination,
} from '@/components/common'
import { CommunityVideoModal } from '@/components/track/approaches-elements/community-videos/CommunityVideoModal'
import { TrackFilterList } from './TrackFilterList'
import { type HandleTrackChangeType, useVideoGrid } from './useVideoGrid'
import type { Request } from '@/hooks'
import type { VideoTrack } from '@/components/types'
import type { CommunityVideoType } from '@/components/types'

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
    isFetching,
    selectedTrack,
    criteria,
    setCriteria,
  } = useVideoGrid(data.request, data.tracks)

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  const timer = useRef<any>()

  const handlePageResetOnInputChange = useCallback(
    (input: string) => {
      //clears it on any input
      clearTimeout(timer.current)
      if (criteria && (input.length > 2 || input.length === 0)) {
        timer.current = setTimeout(() => setPage(1), 500)
      }
    },

    [criteria, setPage]
  )

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
          onChange={(e) => {
            setCriteria(e.target.value)
            handlePageResetOnInputChange(e.target.value)
          }}
        />
      </div>

      <ResultsZone isFetching={isFetching}>
        <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-16">
          {resolvedData && resolvedData.results.length > 0 ? (
            resolvedData.results.map((video) => (
              <Video key={video.embedUrl} video={video} />
            ))
          ) : resolvedData?.meta.unscopedTotal === 0 ? (
            <NoResultsYet />
          ) : (
            <NoResultsOfQuery />
          )}
        </div>
        {resolvedData && (
          <Pagination
            current={page}
            total={resolvedData.meta.totalPages}
            setPage={setPage}
          />
        )}
      </ResultsZone>
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
        status={QueryStatus.Success}
        error={undefined}
        countText={'video'}
      />
    </div>
  )
}

type VideoProps = {
  video: CommunityVideoType
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
        video={video}
      />
    </>
  )
}

function NoResultsOfQuery() {
  return (
    <div className="col-span-4">
      <FilterFallback
        icon="no-result-magnifier"
        title="No videos found."
        description="Try changing your filters to find the video you are looking for."
      />
    </div>
  )
}

function NoResultsYet() {
  return (
    <div className="col-span-4">
      <FilterFallback
        icon="automation"
        svgFilter="filter-textColor6"
        title="There are currently no videos."
        description="Check back here later for more!"
      />
    </div>
  )
}
