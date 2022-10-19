import React from 'react'
import { Avatar, GraphicalIcon } from '../common'

export function VideoList(): JSX.Element {
  return (
    <div className="p-40 bg-white shadow-lgZ1 rounded-16 mb-64">
      <VideoListHeader />
      <div className="grid grid-cols-4 gap-16">
        {new Array(12).fill(
          <Video
            title="Exercism Elixir Track: Community Garden (Agent)"
            author="Bobbi Towers"
            avatarUrl="https://avatars.githubusercontent.com/u/24420806?v=4"
          />
        )}
      </div>
    </div>
  )
}

function VideoListHeader(): JSX.Element {
  return (
    <div className="flex mb-24">
      <GraphicalIcon
        icon="community-video-gradient"
        height={48}
        width={48}
        className="mr-24 self-start"
      />
      <div className="grid gap-8">
        <h2 className="text-h2">Learn from our community</h2>
        <p className="text-p-large">
          Walkthroughs from our community using Exercism
        </p>
      </div>
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
      <div className="self-center bg-borderLight rounded-8 mb-12 w-[280px] pb-[56.25%]"></div>
      <h5 className="text-h5 mb-8">{title}</h5>
      <div className="flex items-center text-left text-textColor6 font-semibold">
        <Avatar className="h-[24px] w-[24px] mr-8" src={avatarUrl} />
        {author}
      </div>
    </button>
  )
}
