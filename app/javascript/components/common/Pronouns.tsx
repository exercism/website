import React from 'react'
import { GenericTooltip } from '../misc/ExercismTippy'
import GraphicalIcon from './GraphicalIcon'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export const Pronouns = ({
  handle,
  pronouns,
}: {
  handle: string
  pronouns?: string[]
}): JSX.Element | null => {
  const { t } = useAppTranslation()
  if (!pronouns || pronouns.length === 0) return null

  const useHandle = handle.toLowerCase() !== pronouns[0].toLowerCase()

  const content = useHandle
    ? createExample(handle, pronouns)
    : t('pronouns.ratherThanUsingPronouns', { handle })

  return (
    <GenericTooltip
      content={content}
      className="text-15 leading-140 !max-w-[420px]"
    >
      <div className="w-fit cursor-default text-textColor6 font-semibold flex items-center gap-8 mb-6">
        <GraphicalIcon
          icon="pronouns"
          className="filter-textColor6"
          width={16}
          height={16}
        />
        {useHandle ? pronouns.join(' / ') : t('pronouns.doNotUsePronouns')}
      </div>
    </GenericTooltip>
  )
}

function createExample(handle: string, pronouns: string[]) {
  const { t } = useAppTranslation()
  const pronounsString = pronouns.join(' / ')
  return (
    <>
      <p>
        {t('pronouns.whenReferringTo', { handle })}{' '}
        <strong className="whitespace-nowrap">{pronounsString}</strong>.{' '}
        {t('pronouns.forExampleIfLeaving', { handle })}
      </p>
      <blockquote className="block border-l-3 border-borderColor6 mt-8 pl-8 italic">
        {t('pronouns.wasGreat', {
          handle,
          pronoun1: pronouns[0],
          pronoun2: pronouns[1],
          pronoun3: pronouns[2],
        })}
      </blockquote>
    </>
  )
}
