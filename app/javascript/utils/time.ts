import dayjs from 'dayjs'
import RelativeTime from 'dayjs/plugin/relativeTime'
dayjs.extend(RelativeTime)

export function fromNow(dateTime: dayjs.ConfigType) {
  return dayjs(dateTime).fromNow()
}
