import React from 'react'
import Icon from '../common/Icon'
import GraphicalIcon from '../common/GraphicalIcon'

export function MiniAdvert({ settingsLink }: { settingsLink: string }) {
  return (
    <div className="flex flex-col items-center py-24">
      <div className="flex gap-20 items-center mb-8">
        <Icon
          icon="exercism-face"
          category="icons"
          alt="Exercism"
          className="h-[64px]"
        />
        <Icon
          icon="sync"
          category="graphics"
          alt="Sync with"
          className="h-[45px]"
        />
        <Icon
          icon="external-site-github"
          category="icons"
          alt="Github"
          className="h-[64px]"
        />
      </div>
      <h2 className="!text-[18px] !mb-4 font-semibold">
        Backup your Solutions to GitHub
      </h2>
      <p className="text-[14px] leading-140 mb-16 text-balance text-center">
        Automatically backup your solutions to GitHub with our automated backup
        tool.
      </p>
      <div className="flex gap-10 text-10 font-semibold mb-16">
        <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
          <GraphicalIcon icon="safe-duo" className="h-[12px]" />
          Safe Backup
        </div>
        <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
          <GraphicalIcon icon="gh-duo" className="h-[12px]" />
          Green Squares
        </div>
        <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
          <GraphicalIcon icon="free-duo" className="h-[12px]" />
          Its Free!
        </div>
      </div>
      <a className="btn btn-xs btn-primary" href={settingsLink}>
        Click for more info
      </a>
    </div>
  )
}
