// namespace: components/tooltips/student-tooltip
export default {
  previousSessions:
    'Mentored <strong>{{total}}</strong> {{total, plural, one {time} other {times}}}{withMentor, select, 0 { but <strong>never</strong> by you} other {, of which <strong>{{withMentor}}</strong> {{withMentor, plural, one {time} other {times}}} by you}}',
  firstSession: 'This will be their <strong>first</strong> mentoring session',
  favorited: 'Favorited',
  trackObjectivesTitle: 'Track objectives',
  unableToLoad: 'Unable to load information',
}
