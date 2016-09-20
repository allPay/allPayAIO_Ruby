# 廠商申請退款範例

require "allpay"

client = Allpay::Client.new({
  # 測試用 MerchantID，請自行帶入 AllPay 提供的 MerchantID
  merchant_id: "2000214",
  # 測試用 Hashkey，請自行帶入 AllPay 提供的 HashKey
  hash_key: "5294y06JbISpM5x9",
  # 測試用 HashIV，請自行帶入 AllPay 提供的 HashIV
  hash_iv: "v77hoKGq4kWxNNIS"
})

result = client.capture({
  # 服務位置
  ServiceURL: "https://payment-stage.allpay.com.tw/Cashier/Capture",
  # 廠商交易編號
  MerchantTradeNo: "TS20160622800005",
  # 廠商申請撥款金額
  CaptureAMT: 30,
  # 要退款給買方的金額
  UserRefundAMT: 270,
  # 若需要處理退款給買方時，需帶姓名和手機號碼
  # 購買人姓名
  UserName: "王大明",
  # 買方手機號碼
  UserCellPhone: "0987654321",
  # 檢查碼，SDK 會依照帶入資料自行計算，若要使用自行算出的數值才需帶入
  # CheckMacValue: "",
  # 特約合作平台商代號
  # PlatformID: "",
  # 是否更改特約合作平台商手續費
  # UpdatePlatformChargeFee: "N",
  # 特約合作平台商手續費
  # PlatformChargeFee: 0,
  # 備註
  # Remark: ""
})
