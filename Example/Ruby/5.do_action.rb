# 信用卡放棄範例

require "allpay"

client = Allpay::Client.new({
  # 測試用 MerchantID，請自行帶入 AllPay 提供的 MerchantID
  merchant_id: "2000214",
  # 測試用 Hashkey，請自行帶入 AllPay 提供的 HashKey
  hash_key: "5294y06JbISpM5x9",
  # 測試用 HashIV，請自行帶入 AllPay 提供的 HashIV
  hash_iv: "v77hoKGq4kWxNNIS"
})

result = client.do_action({
  # 服務位置
  ServiceURL: "https://payment.allpay.com.tw/CreditDetail/DoAction",
  # 廠商交易編號
  MerchantTradeNo: "T20160622800001",
  # allpay 的交易編號
  TradeNo: "1606221340479404",
  # 執行動作: 放棄
  Action: Allpay::ActionType::N,
  # 金額
  TotalAmount: 200,
  # 檢查碼，SDK 會依照帶入資料自行計算，若要使用自行算出的數值才需帶入
  # CheckMacValue: "",
  # 特約合作平台商代號
  # PlatformID: ""
})
