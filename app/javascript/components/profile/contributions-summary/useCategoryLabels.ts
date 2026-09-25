import { useAppTranslation } from '@/i18n/useAppTranslation'
import type { ContributionCategory } from '../../types'

/**
 * The category title and its metric are both translated here rather than
 * shipped as prose from the assembler, which could only ever send English.
 */
export function useCategoryLabels(): {
  title: (category: ContributionCategory) => string
  metric: (
    category: ContributionCategory,
    length: 'metricFull' | 'metricShort'
  ) => string | null
} {
  const { t } = useAppTranslation('components/profile/contributions-summary')

  return {
    title: (category) => t(`category.${category.id}`),
    metric: (category, length) =>
      category.metricCount === undefined
        ? null
        : t(`${length}.${category.id}`, {
            count: category.metricCount,
          }),
  }
}
