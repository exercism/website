import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GetHelpAccordionSkeleton } from './GetHelpAccordionSkeleton'

export function GetHelpPanelCommunityHelp({
  links,
}: Record<
  'links',
  Record<'forumRedirectPath' | 'discordRedirectPath', string>
>): JSX.Element {
  return (
    <GetHelpAccordionSkeleton title="Community help" icon={''}>
      <div className="pt-16 flex flex-col gap-8 px-32">
        <CommunityOpportunity
          name="Discord"
          description="Chat & hang with the community"
          icon="external-site-discord-blue"
          link={links.discordRedirectPath}
        />
        <CommunityOpportunity
          name="Forum"
          description="Dig deeper into topics"
          icon="discourser"
          link={links.forumRedirectPath}
        />
      </div>
    </GetHelpAccordionSkeleton>
  )
}

function CommunityOpportunity({
  name,
  description,
  icon,
  link,
}: Record<'link' | 'name' | 'description' | 'icon', string>) {
  return (
    <a
      href={link}
      target="_blank"
      rel="noreferrer"
      className="px-12 py-10 flex gap-16 items-center rounded-8 hover:bg-backgroundColorD"
    >
      <GraphicalIcon icon={icon} width={32} height={32} />
      <div>
        <h6 className="text-h6 text-textColor1 mb-2">{name}</h6>
        <p className="text-p-small text-textColor1">{description}</p>
      </div>
    </a>
  )
}
