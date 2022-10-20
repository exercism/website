import React, { useState } from 'react'
import { Avatar, GraphicalIcon, Pagination } from '../../common'

type PodcastGridProps = {
  data: any
}

export function PodcastGrid({ data }: PodcastGridProps): JSX.Element {
  const [page, setPage] = useState<number>(1)

  return (
    <div className="p-40 bg-white shadow-lgZ1 rounded-16 mb-64">
      <PodcastGridHeader />
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-16">
        {new Array(12).fill(
          <Podcast
            title="How I Saved My Life with 3D Printing"
            author="Bobbi Towers"
            avatarUrl="https://avatars.githubusercontent.com/u/24420806?v=4"
          />
        )}
      </div>
      <Pagination current={page} total={120} setPage={setPage} />
    </div>
  )
}

function PodcastGridHeader(): JSX.Element {
  return (
    <div className="flex mb-24">
      <GraphicalIcon
        icon="podcast-gradient"
        height={48}
        width={48}
        className="mr-24 self-start"
      />
      <div className="grid gap-8 mr-auto">
        <h2 className="text-h2">More Stories from our community</h2>
        <p className="text-p-large">
          Listen, learn and be inspired by our community members.
        </p>
      </div>
    </div>
  )
}

type PodcastProps = {
  title: string
  author: string
  avatarUrl: string
}
function Podcast({ title, author, avatarUrl }: PodcastProps): JSX.Element {
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
