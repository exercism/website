import React from 'react'
import { useAppTranslation } from '@/i18n/useAppTranslation'
import { usePagination } from './usePagination'

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
  const { t } = useAppTranslation()

  const {
    valid,
    cur,
    tot,
    rangeStart,
    rangeEnd,
    range,
    showLeftEllipsis,
    showRightEllipsis,
    canPrev,
    canNext,
    goFirst,
    goPrev,
    goNext,
    goLast,
    goPage,
  } = usePagination({ disabled, current, total, around, setPage })

  if (!valid) return null

  return (
    <div className="c-pagination">
      <div className="--pagination-lhs">
        <button
          onClick={goFirst}
          disabled={!canPrev}
          aria-label={t('pagination.goToFirstPage')}
        >
          {t('pagination.first')}
        </button>
        <button
          onClick={goPrev}
          disabled={!canPrev}
          aria-label={t('pagination.goToPreviousPage')}
        >
          {t('pagination.previous')}
        </button>
      </div>

      <div className="--pagination-pages">
        {rangeStart > 1 && (
          <button
            key={1}
            onClick={() => goPage(1)}
            aria-label={t('pagination.goToPage', { page: 1 })}
          >
            1
          </button>
        )}

        {showLeftEllipsis && <div className="--pagination-more">…</div>}

        {range.map((page) => (
          <button
            key={page}
            onClick={() => goPage(page)}
            disabled={disabled || page === cur}
            aria-label={t('pagination.goToPage', { page })}
            aria-current={page === cur ? 'page' : undefined}
            className={page === cur ? 'current' : undefined}
          >
            {page}
          </button>
        ))}

        {showRightEllipsis && <div className="--pagination-more">…</div>}

        {rangeEnd < tot && (
          <button
            key={tot}
            onClick={() => goPage(tot)}
            aria-label={t('pagination.goToPage', { page: tot })}
          >
            {tot}
          </button>
        )}
      </div>

      <div className="--pagination-rhs">
        <button
          onClick={goNext}
          disabled={!canNext}
          aria-label={t('pagination.goToNextPage')}
        >
          {t('pagination.next')}
        </button>
        <button
          onClick={goLast}
          disabled={!canNext}
          aria-label={t('pagination.goToLastPage')}
        >
          {t('pagination.last')}
        </button>
      </div>
    </div>
  )
}
