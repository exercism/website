import type { ConfigType } from 'dayjs'
import i18n from '@/i18n/i18n'
import { localisedDayjs } from './dayjs-locale'

/**
 * Deliberately not dayjs's own fromNow(): this rounds on calendar boundaries
 * and has today/yesterday cases, so the wording is translated here instead.
 */
export function fromNow(date: ConfigType, titleize = false): string {
  const now = localisedDayjs()
  const from = localisedDayjs(date)

  const days = now.diff(from, 'day')
  const weeks = now.diff(from, 'week')
  const months = now.diff(from, 'month')
  const years = now.diff(from, 'year')

  if (years >= 1) {
    return i18n.t('utils/date:yearsAgo', { count: years })
  } else if (months >= 1) {
    return i18n.t('utils/date:monthsAgo', { count: months })
  } else if (weeks >= 1) {
    return i18n.t('utils/date:weeksAgo', { count: weeks })
  } else if (days > 1) {
    return i18n.t('utils/date:daysAgo', { count: days })
  } else if (days === 1) {
    return titleize
      ? i18n.t('utils/date:yesterdayTitleized')
      : i18n.t('utils/date:yesterday')
  } else {
    return titleize
      ? i18n.t('utils/date:todayTitleized')
      : i18n.t('utils/date:today')
  }
}
