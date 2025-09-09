import React from 'react'
import { flagForLocale } from '@/utils/flag-for-locale'
import { nameForLocale } from '@/utils/name-for-locale'

type TranslationHeaderProps = {
  locale: string
}

export function TranslationHeader({ locale }: TranslationHeaderProps) {
  return (
    <div className="header">
      <div className="text-h4">
        {nameForLocale(locale)} ({locale})
      </div>
      <div className="status">Needs Reviewing</div>
      <div className="flag">{flagForLocale(locale)}</div>
    </div>
  )
}
