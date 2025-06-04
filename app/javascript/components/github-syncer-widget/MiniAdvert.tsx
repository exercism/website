import React from 'react'
import Icon from '../common/Icon'
import GraphicalIcon from '../common/GraphicalIcon'

export function MiniAdvert({ settingsLink }: { settingsLink: string }) {
  return (
    <div className="flex flex-col items-stretch py-24 text-center px-40">
      <div className="flex gap-20 items-center mb-12 mx-auto">
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
      <h2 className="text-21 text-textColor1 mb-8 font-semibold">
        Backup your Solutions to GitHub
      </h2>
      <p className="text-16 leading-140 mb-12 text-balance text-center">
        Automatically backup your solutions to GitHub with our automated backup
        tool.
      </p>
      <a className="btn btn-m btn-primary mb-24" href={settingsLink}>
        Configure backups
      </a>
    </div>
  )
}
