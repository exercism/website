// i18n-key-prefix: rightPane.considerations
// i18n-namespace: components/training-data/code-tagger
import React from 'react'
import { Trans } from 'react-i18next'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export default function Considerations(): JSX.Element | null {
  const { t } = useAppTranslation()

  return (
    <p className="flex items-center justify-center font-medium text-16 leading-[24px] py-8 px-16 border-2 border-orange rounded-8 bg-bgCAlert text-textCAlert whitespace-nowrap my-16">
      <Trans
        i18nKey="rightPane.considerations.pleaseReadDocs"
        ns="components/training-data/code-tagger"
        components={[
          <a
            href="/docs/building/tooling/analyzers/tags"
            target="_blank"
            rel="noreferrer"
            className="!text-textCAlertLabel underline"
          />,
        ]}
      />
    </p>
  )
}
