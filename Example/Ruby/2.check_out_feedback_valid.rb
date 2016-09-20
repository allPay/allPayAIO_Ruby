# 付款結果通知範例

require "allpay"

client = Allpay::Client.new({
  # 測試用 MerchantID，請自行帶入 AllPay 提供的 MerchantID
  merchant_id: "2000214",
  # 測試用 Hashkey，請自行帶入 AllPay 提供的 HashKey
  hash_key: "5294y06JbISpM5x9",
  # 測試用 HashIV，請自行帶入 AllPay 提供的 HashIV
  hash_iv: "v77hoKGq4kWxNNIS"
})

# 測試用付款結果
feedback_data = {
  "MerchantID"=>"2000214",
  "MerchantTradeNo"=>"TS20160622800001",
  "PayAmt"=>"100",
  "PaymentDate"=>"2016/06/22 09:02:37",
  "PaymentType"=>"Credit_CreditCard",
  "PaymentTypeChargeFee"=>"5",
  "RedeemAmt"=>"0",
  "RtnCode"=>"1",
  "RtnMsg"=>"交易成功",
  "SimulatePaid"=>"0",
  "TradeAmt"=>"100",
  "TradeDate"=>"2016/06/22 09:01:52",
  "TradeNo"=>"1606220901529639",
  "CheckMacValue"=>"B2F453EA8D3AF08E1EF7AB8899E1DF96"
}

# 驗證結果，計算並比對 CheckMacValue 確保資料正確性
result = client.check_out_feedback_valid? feedback_data
