// i18n-key-prefix: getHelpPanelComponents.getHelpPanelCommunityHelp
// i18n-namespace: components/editor/GetHelp
import React from 'react'
import { GraphicalIcon } from '@/components/common'
import { GetHelpAccordionSkeleton } from './GetHelpAccordionSkeleton'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function GetHelpPanelCommunityHelp({
  links,
}: Record<
  'links',
  Record<'forumRedirectPath' | 'discordRedirectPath', string>
>): JSX.Element {
  const { t } = useAppTranslation('components/editor/GetHelp')
  return (
    <GetHelpAccordionSkeleton title="Community help" iconSlug="support">
      <div className="pt-8 flex flex-col gap-2">
        <p className="text-p-base text-color-2 mb-8">
          {t(
            'getHelpPanelComponents.getHelpPanelCommunityHelp.dontStruggleAlone'
          )}
        </p>
        <p className="text-p-base text-color-2 mb-8">
          {t(
            'getHelpPanelComponents.getHelpPanelCommunityHelp.cantSubmitMentoringRequest'
          )}
        </p>
        <CommunityOpportunity
          name="Discord"
          description={t(
            'getHelpPanelComponents.getHelpPanelCommunityHelp.discordDescription'
          )}
          icon="external-site-discord-blue"
          link={links.discordRedirectPath}
        />
        <CommunityOpportunity
          name="Forum"
          description={t(
            'getHelpPanelComponents.getHelpPanelCommunityHelp.forumDescription'
          )}
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
