import React, { useState } from 'react'
import { Avatar, GraphicalIcon, Pagination } from '@/components/common'

type StoriesGridProps = {
  data: any
}

export function StoriesGrid({ data }: StoriesGridProps): JSX.Element | null {
  const [page, setPage] = useState<number>(1)

  if (data.request.options.initialData.meta.totalCount === 0) {
    return null
  }

  return (
    <div className="p-40 bg-backgroundColorA shadow-lgZ1 rounded-16 mb-64">
      <StoriesGridHeader />
      <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-16">
        {data.request.options.initialData.results.map((story: StoryProps) => (
          <Story key={story.title} {...story} />
        ))}
      </div>
      <Pagination
        current={page}
        total={data.request.options.initialData.meta.totalCount}
        setPage={setPage}
      />
    </div>
  )
}

function StoriesGridHeader(): JSX.Element {
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

type StoryProps = {
  title: string
  thumbnailUrl: string
  interviewee: {
    name: string
    handle: string
    avatarUrl: string
  }
  links: {
    self: string
  }
}
function Story({ title, interviewee, links }: StoryProps): JSX.Element {
  return (
    <a href={links.self}>
      <button className="grid shadow-sm p-16 bg-white rounded-8 text-left">
        <div className="self-center bg-borderLight rounded-8 mb-12 max-w-[100%] pb-[46.25%]"></div>
        <h5 className="text-h5 mb-8">{title}</h5>
        <div className="flex items-center text-left text-textColor6 font-semibold">
          <Avatar
            className="h-[24px] w-[24px] mr-8"
            src={interviewee.avatarUrl}
          />
          {interviewee.name}
        </div>
      </button>
    </a>
  )
}
export default StoriesGrid
