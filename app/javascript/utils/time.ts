import type { ConfigType } from 'dayjs'
import pluralize from 'pluralize'
import { localisedDayjs, shortRelative } from './dayjs-locale'

const SECONDS_PER_MINUTE = 60
const SECONDS_PER_HOUR = SECONDS_PER_MINUTE * 60
const SECONDS_PER_DAY = SECONDS_PER_HOUR * 24
const SECONDS_PER_MONTH = SECONDS_PER_DAY * 31

export function fromNow(dateTime: ConfigType) {
  return localisedDayjs(dateTime).fromNow()
}

// Turns "2 days ago" into "2d ago".
export const shortFromNow = shortRelative

export function timeFormat(dateTime: ConfigType, template: string) {
  return localisedDayjs(dateTime).format(template)
}

export function durationFromSeconds(seconds: number): string {
  const duration = (limit: number, unitDivider: number, unit: string) => {
    if (seconds < limit) {
      const units = Math.floor(seconds / unitDivider)
      return `${units} ${pluralize(unit, units)}`
    }

    return null
  }

  return (duration(SECONDS_PER_MINUTE, 1, 'second') ||
    duration(SECONDS_PER_HOUR, SECONDS_PER_MINUTE, 'minute') ||
    duration(SECONDS_PER_DAY, SECONDS_PER_HOUR, 'hour') ||
    duration(SECONDS_PER_MONTH, SECONDS_PER_DAY, 'day') ||
    duration(Number.MAX_VALUE, SECONDS_PER_MONTH, 'month'))!
}

export function durationTimeElementFromSeconds(seconds: number) {
  const days = Math.floor(seconds / SECONDS_PER_DAY)
  seconds %= SECONDS_PER_DAY

  const hours = Math.floor(seconds / SECONDS_PER_HOUR)
  seconds %= SECONDS_PER_HOUR

  const minutes = Math.floor(seconds / SECONDS_PER_MINUTE)
  seconds %= SECONDS_PER_MINUTE

  return `P ${days}D ${hours}H ${minutes}M ${seconds}S`
}
