# 信用卡定期定額訂單查詢範例

require "allpay"

client = Allpay::Client.new({
  # 測試用 MerchantID，請自行帶入 AllPay 提供的 MerchantID
  merchant_id: "2000214",
  # 測試用 Hashkey，請自行帶入 AllPay 提供的 HashKey
  hash_key: "5294y06JbISpM5x9",
  # 測試用 HashIV，請自行帶入 AllPay 提供的 HashIV
  hash_iv: "v77hoKGq4kWxNNIS"
})

result = client.query_credit_card_period_info({
  # 服務位置
  ServiceURL: "https://payment-stage.allpay.com.tw/Cashier/QueryCreditCardPeriodInfo",
  # 廠商交易編號
  MerchantTradeNo: "TS20160622800003",
  # 檢查碼，SDK 會依照帶入資料自行計算，若要使用自行算出的數值才需帶入
  # CheckMacValue: ""
})
