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
    <GetHelpAccordionSkeleton title="Community help" iconSlug="support">
      <div className="pt-8 flex flex-col gap-2">
        <p className="text-p-base text-color-2 mb-8">
          Don&apos;t struggle on alone! Our community is always here to help.
        </p>
        <p className="text-p-base text-color-2 mb-8">
          Although you can&apos;t submit a mentoring requests until you get the
          tests passing, you can ask for help on Discord or our Forum. Use the
          links below to get started:
        </p>
        <CommunityOpportunity
          name="Discord"
          description="Get real time help in the #support channel on our Discord server."
          icon="external-site-discord-blue"
          link={links.discordRedirectPath}
        />
        <CommunityOpportunity
          name="Forum"
          description="Dig deeper into topics and ideas on our forum."
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
        <p className="text-p-base text-textColor5">{description}</p>
      </div>
    </a>
  )
}
