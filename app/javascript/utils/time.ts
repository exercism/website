import dayjs from 'dayjs'
import type { ConfigType } from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(RelativeTime)

export function fromNow(dateTime: ConfigType) {
  return dayjs(dateTime).fromNow()
}
