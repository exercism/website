// i18n-key-prefix: articles
// i18n-namespace: components/track/dig-deeper-components
import React, { useContext } from 'react'
import { ArticleSnippet, SectionHeader } from '.'
import { Article, DigDeeperDataContext } from '../DigDeeper'
import { useAppTranslation } from '@/i18n/useAppTranslation'

export function Articles({ articles }: { articles: Article[] }): JSX.Element {
  const { exercise } = useContext(DigDeeperDataContext)
  const { t } = useAppTranslation()

  return (
    <div className="flex flex-col">
      <SectionHeader
        title={t('sectionHeader.articles')}
        description={
          articles.length > 0
            ? t('sectionHeader.exploreMoreIdeas')
            : t('sectionHeader.noArticles', { exerciseTitle: exercise.title })
        }
        icon="dig-deeper-gradient"
        className="mb-16"
      />

      <div className="lg:flex lg:flex-col grid grid-cols-1 md:grid-cols-2 gap-x-16 lg:gap-x-[unset]">
        {articles.length > 0 &&
          articles.map((i) => {
            return <ArticleSnippet key={i.title} article={i} />
          })}
      </div>
    </div>
  )
}
