// i18n-key-prefix: languagePreferenceForm
// i18n-namespace: components/settings/LanguagePreferenceForm.tsx
import React, { useCallback } from 'react'
import {
  LanguageField,
  useLanguageField,
  type Language,
} from './language-preference-form'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type LanguagePreferenceLinks = {
  update: string
}

export type LanguagePreferenceFormProps = {
  languages: Language[]
  comingSoonLanguages: Language[]
  defaultLocale: string
  links: LanguagePreferenceLinks
}

export default function LanguagePreferenceForm({
  languages,
  comingSoonLanguages,
  defaultLocale,
  links,
}: LanguagePreferenceFormProps): JSX.Element {
  const { t } = useAppTranslation(
    'components/settings/LanguagePreferenceForm.tsx'
  )
  const redirectPathFor = useCallback(
    (code: string) =>
      languages.find((language) => language.code === code)?.redirectPath,
    [languages]
  )

  const { locale, select, status } = useLanguageField(
    defaultLocale,
    links.update,
    redirectPathFor
  )

  return (
    <form data-turbo="false">
      <h2 className="!mb-4">{t('languagePreferenceForm.language')}</h2>
      <p className="text-p-base mb-12">
        {t('languagePreferenceForm.description')}
      </p>
      <LanguageField
        languages={languages}
        comingSoonLanguages={comingSoonLanguages}
        locale={locale}
        saving={status === 'loading'}
        onSelect={select}
      />
    </form>
  )
}
