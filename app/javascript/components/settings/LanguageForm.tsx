// i18n-key-prefix: languageForm
// i18n-namespace: components/settings/LanguageForm.tsx
import React from 'react'
import { SingleSelect } from '../common/SingleSelect'
import { FormMessage } from './FormMessage'
import { useLanguageField } from './language-form/useLanguageField'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export type Language = {
  code: string
  native: string
  english: string
}

type Links = {
  update: string
}

const DEFAULT_ERROR = new Error('Unable to save your language')

export default function LanguageForm({
  languages,
  defaultLocale,
  links,
}: {
  languages: Language[]
  defaultLocale: string
  links: Links
}): JSX.Element {
  const { t } = useAppTranslation('components/settings/LanguageForm.tsx')
  const { locale, select, status, error } = useLanguageField(
    defaultLocale,
    links.update
  )

  const selected =
    languages.find((language) => language.code === locale) || languages[0]

  return (
    <form data-turbo="false" onSubmit={(e) => e.preventDefault()}>
      <h2>{t('languageForm.language')}</h2>
      <div className="instructions">{t('languageForm.instructions')}</div>

      <div className="language field">
        <SingleSelect<Language>
          className="w-[280px]"
          options={languages}
          value={selected}
          setValue={(language) => select(language.code)}
          SelectedComponent={LanguageOption}
          OptionComponent={LanguageOption}
        />
      </div>

      <FormMessage
        status={status}
        defaultError={DEFAULT_ERROR}
        error={error}
        SuccessMessage={NoSuccessMessage}
      />
    </form>
  )
}

const NoSuccessMessage = (): null => null

function LanguageOption({ option }: { option: Language }): JSX.Element {
  return (
    <div className="flex flex-col text-left">
      <span lang={option.code}>{option.native}</span>
      <span className="text-13 text-textColor6">{option.english}</span>
    </div>
  )
}
