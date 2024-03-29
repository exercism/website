module ReactComponents
  module Impact
    class Chart < ReactComponent
      def to_s
        super(
          "impact-chart",
          {
            users_per_month: USERS_PER_MONTH,
            milestones: MILESTONES
          }
        )
      end

      MILESTONES = [
        { date: '202207', text: 'Reached 1M users!', emoji: '🤩' },
        { date: '202109', text: 'Exercism v3', emoji: '3️⃣' },
        { date: '202006', text: 'Automated feedback!', emoji: '🤖' },
        { date: '201807', text: 'Exercism v2', emoji: '2️⃣' },
        { date: '201312', text: 'Exercism launched', emoji: '🚀' }
      ].to_json

      USERS_PER_MONTH = {
        '201305': 0,
        '201306': 91,
        '201307': 1892,
        '201308': 2470,
        '201309': 1228,
        '201310': 1355,
        '201311': 623,
        '201312': 726,
        '201401': 898,
        '201402': 1491,
        '201403': 1036,
        '201404': 976,
        '201405': 1766,
        '201406': 994,
        '201407': 810,
        '201408': 891,
        '201409': 41_182,
        '201410': 6617,
        '201411': 3048,
        '201412': 2990,
        '201501': 3792,
        '201502': 2454,
        '201503': 1921,
        '201504': 5766,
        '201505': 1827,
        '201506': 1708,
        '201507': 1951,
        '201508': 1502,
        '201509': 1401,
        '201510': 2059,
        '201511': 1751,
        '201512': 1864,
        '201601': 1573,
        '201602': 1868,
        '201603': 2096,
        '201604': 1799,
        '201605': 2491,
        '201606': 2455,
        '201607': 2452,
        '201608': 2816,
        '201609': 2270,
        '201610': 2436,
        '201611': 2368,
        '201612': 2376,
        '201701': 3607,
        '201702': 5533,
        '201703': 4133,
        '201704': 3172,
        '201705': 3420,
        '201706': 3509,
        '201707': 3731,
        '201708': 3486,
        '201709': 3269,
        '201710': 3884,
        '201711': 3211,
        '201712': 6013,
        '201801': 3861,
        '201802': 3269,
        '201803': 3352,
        '201804': 3069,
        '201805': 3051,
        '201806': 3233,
        '201807': 6992,
        '201808': 10_684,
        '201809': 9601,
        '201810': 9433,
        '201811': 9692,
        '201812': 8084,
        '201901': 12_933,
        '201902': 10_699,
        '201903': 11_388,
        '201904': 9717,
        '201905': 10_055,
        '201906': 12_078,
        '201907': 11_785,
        '201908': 12_440,
        '201909': 10_952,
        '201910': 11_443,
        '201911': 11_524,
        '201912': 12_302,
        '202001': 15_134,
        '202002': 16_145,
        '202003': 16_406,
        '202004': 19_080,
        '202005': 17_446,
        '202006': 16_067,
        '202007': 15_726,
        '202008': 16_559,
        '202009': 16_079,
        '202010': 14_135,
        '202011': 13_659,
        '202012': 16_674,
        '202101': 16_348,
        '202102': 17_173,
        '202103': 20_084,
        '202104': 17_827,
        '202105': 17_425,
        '202106': 17_335,
        '202107': 17_548,
        '202108': 15_637,
        '202109': 20_881,
        '202110': 20_478,
        '202111': 20_625,
        '202112': 21_350,
        '202201': 39_627,
        '202202': 37_265,
        '202203': 31_452,
        '202204': 32_129,
        '202205': 30_835,
        '202206': 27_225,
        '202207': 28_627,
        '202208': 31_832,
        '202209': 31_832
      }.to_json
    end
  end
end
