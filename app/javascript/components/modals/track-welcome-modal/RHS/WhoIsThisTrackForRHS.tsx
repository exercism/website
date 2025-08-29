import React from 'react'
import VimeoEmbed from '@/components/common/VimeoEmbed'
import { Icon } from '@/components/common'
import { GraphicalIcon } from '@/components/common'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { Trans } from 'react-i18next'

export function WhoIsThisTrackForRHS(): JSX.Element {
  const { t } = useAppTranslation('components/modals/track-welcome-modal/RHS')

  return (
    <div className="rhs" data-capy-element="who-is-this-track-for-rhs">
      <div className="rounded-8 p-20 bg-backgroundColorD border-1 border-borderColor7 mb-16">
        <div className="flex flex-row gap-8 items-center justify-center text-16 text-textColor1 mb-16">
          <Icon
            icon="exercism-face"
            className="filter-textColor1"
            alt="exercism-face"
            height={16}
            width={16}
          />
          <div>
            <Trans
              ns="components/modals/track-welcome-modal/RHS"
              i18nKey="whoIsThisTrackFor.courseName"
              components={{ strong: <strong className="font-semibold" /> }}
              parent="span"
            />
          </div>
        </div>
        <VimeoEmbed className="rounded-8 mb-16" id="1068683543?h=2de237a304" />
        <div className="text-16 leading-150 text-textColor2">
          <p className="mb-12 text-17 font-semibold">
            {t('whoIsThisTrackFor.courseOffersHeading')}
          </p>
          <ul className="flex flex-col gap-8 text-16 font-regular">
            <li className="flex items-start">
              <GraphicalIcon
                icon="wave"
                category="bootcamp"
                className="mr-8 w-[20px]"
              />
              <Trans
                ns="components/modals/track-welcome-modal/RHS"
                i18nKey="whoIsThisTrackFor.courseOffers.expertTeaching"
                components={{ strong: <strong className="font-semibold" /> }}
                parent="span"
              />
            </li>
            <li className="flex items-start">
              <GraphicalIcon
                icon="fun"
                category="bootcamp"
                className="mr-8 w-[20px]"
              />
              <Trans
                ns="components/modals/track-welcome-modal/RHS"
                i18nKey="whoIsThisTrackFor.courseOffers.handsOnProjects"
                components={{ strong: <strong className="font-semibold" /> }}
                parent="span"
              />
            </li>
            <li className="flex items-start">
              <GraphicalIcon
                icon="complete"
                category="bootcamp"
                className="mr-8 w-[20px]"
              />
              <Trans
                ns="components/modals/track-welcome-modal/RHS"
                i18nKey="whoIsThisTrackFor.courseOffers.completeSyllabus"
                components={{ strong: <strong className="font-semibold" /> }}
                parent="span"
              />
            </li>
            <li className="flex items-start">
              <GraphicalIcon
                icon="certificate"
                category="bootcamp"
                className="mr-8 w-[20px]"
              />
              <Trans
                ns="components/modals/track-welcome-modal/RHS"
                i18nKey="whoIsThisTrackFor.courseOffers.certificate"
                components={{ strong: <strong className="font-semibold" /> }}
                parent="span"
              />
            </li>
          </ul>
        </div>
      </div>
    </div>
  )
}
