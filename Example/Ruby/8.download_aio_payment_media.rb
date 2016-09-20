# 下載廠商對帳媒體檔範例

require "allpay"

client = Allpay::Client.new({
  # 測試用 MerchantID，請自行帶入 AllPay 提供的 MerchantID
  merchant_id: "2000214",
  # 測試用 Hashkey，請自行帶入 AllPay 提供的 HashKey
  hash_key: "5294y06JbISpM5x9",
  # 測試用 HashIV，請自行帶入 AllPay 提供的 HashIV
  hash_iv: "v77hoKGq4kWxNNIS"
})

result = client.download_aio_payment_media({
  # 服務位置
  ServiceURL: "https://vendor-stage.allpay.com.tw/PaymentMedia/TradeNoAio",
  # 查詢日期類別: 付款日期
  DateType: Allpay::TradeDateType::PAYMENT,
  # 查詢開始日期
  BeginDate: "2016-06-22",
  # 查詢結束日期
  EndDate: "2016-06-22",
  # CSV 格式: 新版
  MediaFormated: Allpay::MediaFormat::NEW,
  # 儲存檔案的實體路徑(含檔名)
  FilePath: "/tmp/aio_payment_media.csv",
  # 付款方式: 信用卡付費
  # PaymentType: Allpay::PaymentType::CREDIT,
  # 訂單類型: 一般
  # PlatformStatus: Allpay::PlatformStatus::GENERAL,
  # 付款狀態: 已付款
  # PaymentStatus: Allpay::PaymentStatus::PAID,
  # 撥款狀態: 已撥款
  # AllocateStauts: Allpay::AllocateStauts::APPROPRIATIONS,
  # 檢查碼，SDK 會依照帶入資料自行計算，若要使用自行算出的數值才需帶入
  # CheckMacValue: ""
})
