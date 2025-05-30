import React from 'react'
import { GitHubSyncerContext } from '../GitHubSyncerForm'
import { GraphicalIcon, Icon } from '@/components/common'

export function ConnectToGithubSection() {
  const { links } = React.useContext(GitHubSyncerContext)
  return (
    <section>
      <div className="flex flex-col items-center max-w-[500px] mx-auto">
        <div className="flex gap-20 items-center mb-8">
          <Icon
            icon="exercism-face"
            category="icons"
            alt="Exercism"
            className="mb-16 h-[128px]"
          />
          <Icon
            icon="sync"
            category="graphics"
            alt="Sync with"
            className="mb-16 h-[90px]"
          />
          <Icon
            icon="external-site-github"
            category="icons"
            alt="Github"
            className="mb-16 h-[128px]"
          />
        </div>
        <h2 className="!text-[30px] !mb-4">Backup your Solutions to GitHub</h2>
        <p className="text-[19px] leading-140 mb-16 text-balance text-center">
          Automatically backup your solutions to GitHub with our automated
          backup tool.
        </p>
        <div className="flex gap-10 text-15 font-semibold">
          <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
            <GraphicalIcon icon="safe-duo" className="h-[20px]" />
            Safe Backup
          </div>
          <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
            <GraphicalIcon icon="gh-duo" className="h-[20px]" />
            Green Squares
          </div>
          <div className="flex items-center rounded-100 font-medium bg-bootcamp-light-purple text-purple border-1 border-purple py-6 px-12 gap-6">
            <GraphicalIcon icon="free-duo" className="h-[20px]" />
            Its Free!
          </div>
        </div>
        <GraphicalIcon icon="arrow-down-duo" className="h-[32px] my-32" />

        <ol className="text-20 leading-140 mb-16 ml-[40px]">
          <li className="mb-12 relative">
            <GraphicalIcon
              icon="1-duo.svg"
              className="h-[32px] !absolute left-[-40px] top-[4px]"
            />
            Ensure you have a GitHub repository ready to use.
          </li>

          <li className="mb-12 relative">
            <GraphicalIcon
              icon="2-duo.svg"
              className="h-[32px] !absolute left-[-40px] top-[4px]"
            />
            Click the button below to connect your GitHub account.
          </li>

          <li className="mb-12 relative">
            <GraphicalIcon
              icon="3-duo.svg"
              className="h-[32px] !absolute left-[-40px] top-[4px]"
            />
            Use the "Backup Everything" option to backup all your existing
            solutions.
          </li>

          <li className="mb-12 relative">
            <GraphicalIcon
              icon="4-duo.svg"
              className="h-[32px] !absolute left-[-40px] top-[4px]"
            />
            Future solutions will be automatically backed up as you complete
            exercises.
          </li>
        </ol>
        <a
          className="btn btn-l btn-primary w-fit"
          href={links?.connectToGithub}
        >
          Connect a GitHub repo
        </a>
      </div>
    </section>
  )
}
