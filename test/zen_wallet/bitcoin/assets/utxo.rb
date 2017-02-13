# frozen_string_literal: true
MAX_AMOUNT = 250_453_000
MAX_CONFIRMED_AMOUNT = 24_000_000
TOTAL_AMOUNT = 348_897_999
TOTAL_CONFIRMED_AMOUNT = 54_000_000
MIN_AMOUNT = 2_000_000
UTXO = [
  {
    address: "mqyY6uXNy2gzipamqbd56k2bVB6QutTGTW",
    txid: "1b2e3d913f08906d448e185ec777aaecf90b371aee39f790387f91859cf5840c",
    vout: 1,
    amount: 250_453_000,
    script: "76a91472b84b4f00244817aaf856e24631dea8485bcf7188ac",
    confirmations: 0
  },

  {
    address: "mqyY6uXNy2gzipamqbd56k2bVB6QutTGTW",
    txid: "1b2e3d913f08906d448e185ec777aaecf90b371aee39f790387f91859cf5840c",
    vout: 0,
    amount: 44_444_000,
    script: "76a91435d51b8e208c97264c93b41958094db96648afc988ac",
    confirmations: 0
  },

  {
    address: "mfr28EK96Vm4UzJP2soJj5tzWLSQrdWpZo",
    txid: "1b2e3d913f08906d448e185ec777aaecf90b371aee39f790387f91859cf5840c",
    vout: 0,
    amount: 24_000_000,
    script: "76a9144b31076176e55e2f53e475d3c649b4d8649de2b388ac",
    confirmations: 294
  },

  {
    address: "mfr28EK96Vm4UzJP2soJj5tzWLSQrdWpZo",
    txid: "952687d175db558715889ee05af4d2c2773664b0f98c693e664ae7a6dfc5c403",
    vout: 0,
    amount: 9_000_999,
    script: "76a91472b84b4f00244817aaf856e24631dea8485bcf7188ac",
    confirmations: 294
  },

  {
    address: "mmKZdz6H434VQoPSJLfG19so8sLPu5edpN",
    txid: "7630902902edfa6e30d09a3a5775c15febe2695d1f16f0b4c4c1fa85e64e88cd",
    vout: 0,
    amount: 2_000_000,
    script: "76a9143fa9443c5df45616f6f51bac47afff6bddb69f4388ac",
    confirmations: 294
  },

  {
    address: "mnNXi2Meu1ZipQvfARk1j22c3xNfTBdee3",
    txid: "952687d175db558715889ee05af4d2c2773664b0f98c693e664ae7a6dfc5c403",
    vout: 0,
    amount: 19_000_000,
    script: "76a9144b31076176e55e2f53e475d3c649b4d8649de2b388ac",
    confirmations: 294
  }
].shuffle.map { |u_attrs| ZenWallet::CommonStructs::Utxo.new(u_attrs) }.freeze
