import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'

type PaginationProps = {
  disabled?: boolean
  current: number
  total: number
  around?: number
  setPage: (page: number) => void
}

export function Pagination({
  disabled = false,
  current = 1,
  total,
  setPage,
  around = 2,
}: PaginationProps): JSX.Element | null {
  const { t } = useAppTranslation('components/common/Pagination.tsx')

  const cur = Number(current)
  const tot = Number(total)
  const ar = Number(around)

  if (isNaN(cur) || isNaN(tot) || tot <= 1) {
    return null
  }

  if (cur < 1) {
    setPage(1)
    return null
  }
  if (cur > tot) {
    setPage(tot)
    return null
  }

  const rangeStart = Math.max(cur - ar, 1)
  const rangeEnd = Math.min(cur + ar, tot)
  const range = createRange(rangeStart, rangeEnd)

  return (
    <div className="c-pagination">
      <div className="--pagination-lhs">
        <button
          onClick={() => setPage(1)}
          disabled={disabled || cur === 1}
          aria-label={t('pagination.goToFirstPage')}
        >
          {t('pagination.first')}
        </button>
        <button
          onClick={() => setPage(cur - 1)}
          disabled={disabled || cur === 1}
          aria-label={t('pagination.goToPreviousPage')}
        >
          {t('pagination.previous')}
        </button>
      </div>

      <div className="--pagination-pages">
        {rangeStart > 1 && (
          <button
            key={1}
            onClick={() => setPage(1)}
            aria-label={t('pagination.goToPage', { page: 1 })}
          >
            1
          </button>
        )}

        {rangeStart > 2 && <div className="--pagination-more">…</div>}

        {range.map((page) => (
          <button
            key={page}
            onClick={() => setPage(page)}
            disabled={disabled || page === cur}
            aria-label={t('pagination.goToPage', { page })}
            aria-current={page === cur ? 'page' : undefined}
            className={page === cur ? 'current' : undefined}
          >
            {page}
          </button>
        ))}

        {rangeEnd < tot && <div className="--pagination-more">…</div>}

        {rangeEnd < tot && (
          <button
            key={tot}
            onClick={() => setPage(tot)}
            aria-label={t('pagination.goToPage', { page: tot })}
          >
            {tot}
          </button>
        )}
      </div>

      <div className="--pagination-rhs">
        <button
          onClick={() => setPage(cur + 1)}
          disabled={disabled || cur === tot}
          aria-label={t('pagination.goToNextPage')}
        >
          {t('pagination.next')}
        </button>
        <button
          onClick={() => setPage(tot)}
          disabled={disabled || cur === tot}
          aria-label={t('pagination.goToLastPage')}
        >
          {t('pagination.last')}
        </button>
      </div>
    </div>
  )
}

function createRange(start: number, end: number): number[] {
  return Array.from({ length: end - start + 1 }, (_, i) => start + i)
}
