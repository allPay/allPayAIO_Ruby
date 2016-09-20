/require "spec_helper"/
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'allpay'
require 'fileutils'
require 'rspec'

client = Allpay::Client.new(merchant_id: "2000214", hash_key: "5294y06JbISpM5x9", hash_iv: "v77hoKGq4kWxNNIS")

describe Allpay do
  describe ".aio_check_out" do
    it "should check parameter type" do
      expect {client.aio_check_out(nil)}.to raise_error(ArgumentError, /\AParameter should be \w+\z/)
    end

    it "should check required parameter" do
      expect {client.aio_check_out({
        MerchantTradeNo: "TS20160622800001",
        MerchantTradeDate: "2016/06/22 01:00:00",
        TotalAmount: 100,
        TradeDesc: "Hello World 網路商城",
        Items: [{
          name: "德國原裝進口自動鉛筆",
          price: 60,
          currency: "元",
          quantity: 1
        }, {
          name: "橡皮擦",
          price: 20,
          currency: "元",
          quantity: 2
        }],
        ReturnURL: "http://localhost/receive",
        ChoosePayment: Allpay::PaymentMethod::ALL
      })}.to raise_error(ArgumentError, /\AMissing required parameter: \w+\z/)
    end

    it "should check parameter format" do
      expect {client.aio_check_out({
        ServiceURL: "https://payment-stage.allpay.com.tw/Cashier/AioCheckOut/V2",
        MerchantTradeNo: "TS20160622800001",
        MerchantTradeDate: "2016-06-22 01:00:00",
        TotalAmount: 100,
        TradeDesc: "Hello World 網路商城",
        Items: [{
          name: "德國原裝進口自動鉛筆",
          price: 60,
          currency: "元",
          quantity: 1
        }, {
          name: "橡皮擦",
          price: 20,
          currency: "元",
          quantity: 2
        }],
        ReturnURL: "http://localhost/receive",
        ChoosePayment: Allpay::PaymentMethod::ALL
      })}.to raise_error(ArgumentError, /\AThe format for \w+ is wrong\z/)
    end

    it "should return checkout form data with MD5 CheckMacValue" do
      result = client.aio_check_out({
        ServiceURL: "https://payment-stage.allpay.com.tw/Cashier/AioCheckOut/V2",
        MerchantTradeNo: "TS20160622800001",
        MerchantTradeDate: "2016/06/22 01:00:00",
        TotalAmount: 100,
        TradeDesc: "Hello World 網路商城",
        Items: [{
          name: "德國原裝進口自動鉛筆",
          price: 60,
          currency: "元",
          quantity: 1
        }, {
          name: "橡皮擦",
          price: 20,
          currency: "元",
          quantity: 2
        }],
        ReturnURL: "http://localhost/receive",
        ChoosePayment: Allpay::PaymentMethod::ALL
      })

      expect(result["Data"]).to be_a(Hash)
      expect(result["Html"]).to match(/^<meta.+<\/form>$/)
      expect(result["Data"]["MerchantID"]).to eq(client.merchant_id)
      expect(result["Data"]["PaymentType"]).to eq("aio")
      expect(result["Data"]["MerchantTradeNo"]).to eq("TS20160622800001")
      expect(result["Data"]["MerchantTradeDate"]).to eq("2016/06/22 01:00:00")
      expect(result["Data"]["TotalAmount"]).to eq(100)
      expect(result["Data"]["TradeDesc"]).to eq("Hello World 網路商城")
      expect(result["Data"]["ReturnURL"]).to eq("http://localhost/receive")
      expect(result["Data"]["ChoosePayment"]).to eq("ALL")
      expect(result["Data"]["ItemName"]).to eq("德國原裝進口自動鉛筆 60 元 x 1#橡皮擦 20 元 x 2")
      expect(result["Data"]["CheckMacValue"]).to eq("14CB214EF5271B870FC75F91329357C9")
    end

    it "should return checkout form data with SHA256 CheckMacValue" do
      result = client.aio_check_out({
        ServiceURL: "https://payment-stage.allpay.com.tw/Cashier/AioCheckOut/V2",
        MerchantTradeNo: "TS20160622800001",
        MerchantTradeDate: "2016/06/22 01:00:00",
        TotalAmount: 100,
        TradeDesc: "Hello World 網路商城",
        EncryptType: Allpay::EncryptType::SHA256,
        Items: [{
          name: "德國原裝進口自動鉛筆",
          price: 60,
          currency: "元",
          quantity: 1
        }, {
          name: "橡皮擦",
          price: 20,
          currency: "元",
          quantity: 2
        }],
        ReturnURL: "http://localhost/receive",
        ChoosePayment: Allpay::PaymentMethod::ALL
      })

      expect(result["Data"]).to be_a(Hash)
      expect(result["Html"]).to match(/^<meta.+<\/form>$/)
      expect(result["Data"]["MerchantID"]).to eq(client.merchant_id)
      expect(result["Data"]["PaymentType"]).to eq("aio")
      expect(result["Data"]["MerchantTradeNo"]).to eq("TS20160622800001")
      expect(result["Data"]["MerchantTradeDate"]).to eq("2016/06/22 01:00:00")
      expect(result["Data"]["TotalAmount"]).to eq(100)
      expect(result["Data"]["TradeDesc"]).to eq("Hello World 網路商城")
      expect(result["Data"]["EncryptType"]).to eq(1)
      expect(result["Data"]["ReturnURL"]).to eq("http://localhost/receive")
      expect(result["Data"]["ChoosePayment"]).to eq("ALL")
      expect(result["Data"]["ItemName"]).to eq("德國原裝進口自動鉛筆 60 元 x 1#橡皮擦 20 元 x 2")
      expect(result["Data"]["CheckMacValue"]).to eq("C5FBAD71FC508663A280B59457520FA1F4D5254353DD23533653939046518BF8")
    end

    it "should return checkout form data with e-invoice" do
      result = client.aio_check_out({
        ServiceURL: "https://payment-stage.allpay.com.tw/Cashier/AioCheckOut/V2",
        MerchantTradeNo: "TS20160622800002",
        MerchantTradeDate: "2016/06/22 02:00:00",
        TotalAmount: 100,
        TradeDesc: "Hello World 網路商城",
        Items: [{
          name: "德國原裝進口自動鉛筆",
          price: 60,
          currency: "元",
          quantity: 1,
        }, {
          name: "橡皮擦",
          price: 20,
          currency: "元",
          quantity: 2,
        }],
        ReturnURL: "http://localhost/receive",
        ChoosePayment: Allpay::PaymentMethod::ALL,
        InvoiceMark: Allpay::InvoiceMark::YES,
        RelateNumber: "TS20160622800002",
        CustomerPhone: "0987654321",
        TaxType: Allpay::TaxType::DUTIABLE,
        CarruerType: Allpay::CarrierType::NONE,
        Donation: Allpay::Donation::NO,
        Print: Allpay::PrintMark::NO,
        InvoiceItems: [{
          name: "德國原裝進口自動鉛筆",
          count: 1,
          word: "支",
          price: 60,
          taxType: Allpay::TaxType::DUTIABLE
        }, {
          name: "橡皮擦",
          count: 2,
          word: "個",
          price: 20,
          taxType: Allpay::TaxType::DUTIABLE
        }],
        InvType: Allpay::InvType::GENERAL
      })

      expect(result["Data"]).to be_a(Hash)
      expect(result["Html"]).to match(/^<meta.+<\/form>$/)
      expect(result["Data"]["MerchantID"]).to eq(client.merchant_id)
      expect(result["Data"]["PaymentType"]).to eq("aio")
      expect(result["Data"]["MerchantTradeNo"]).to eq("TS20160622800002")
      expect(result["Data"]["MerchantTradeDate"]).to eq("2016/06/22 02:00:00")
      expect(result["Data"]["TotalAmount"]).to eq(100)
      expect(result["Data"]["TradeDesc"]).to eq("Hello World 網路商城")
      expect(result["Data"]["ReturnURL"]).to eq("http://localhost/receive")
      expect(result["Data"]["ChoosePayment"]).to eq("ALL")
      expect(result["Data"]["InvoiceMark"]).to eq("Y")
      expect(result["Data"]["RelateNumber"]).to eq("TS20160622800002")
      expect(result["Data"]["CustomerPhone"]).to eq("0987654321")
      expect(result["Data"]["TaxType"]).to eq("1")
      expect(result["Data"]["CarruerType"]).to eq("")
      expect(result["Data"]["Donation"]).to eq("2")
      expect(result["Data"]["Print"]).to eq("0")
      expect(result["Data"]["InvType"]).to eq("07")
      expect(result["Data"]["ItemName"]).to eq("德國原裝進口自動鉛筆 60 元 x 1#橡皮擦 20 元 x 2")
      expect(result["Data"]["CustomerName"]).to eq("")
      expect(result["Data"]["CustomerAddr"]).to eq("")
      expect(result["Data"]["CustomerEmail"]).to eq("")
      expect(result["Data"]["InvoiceItemName"]).to eq("%e5%be%b7%e5%9c%8b%e5%8e%9f%e8%a3%9d%e9%80%b2%e5%8f%a3%e8%87%aa%e5%8b%95%e9%89%9b%e7%ad%86|%e6%a9%a1%e7%9a%ae%e6%93%a6")
      expect(result["Data"]["InvoiceItemCount"]).to eq("1|2")
      expect(result["Data"]["InvoiceItemWord"]).to eq("%e6%94%af|%e5%80%8b")
      expect(result["Data"]["InvoiceItemPrice"]).to eq("60|20")
      expect(result["Data"]["InvoiceItemTaxType"]).to eq("1|1")
      expect(result["Data"]["InvoiceRemark"]).to eq("")
      expect(result["Data"]["DelayDay"]).to eq(0)
      expect(result["Data"]["CheckMacValue"]).to eq("FA4E3B6D5B63D2346C8FA70EC653EA68")
    end
  end

  describe ".check_out_feedback_valid" do
    it "should check parameter type" do
      expect {client.check_out_feedback_valid?(nil)}.to raise_error(ArgumentError, /\AParameter should be \w+\z/)
    end

    it "should verify check out feedback data" do
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

      result = client.check_out_feedback_valid? feedback_data

      expect(result).to be_a(Hash)
    end
  end

  describe ".query_trade_info" do
    it "should check parameter type" do
      expect {client.query_trade_info(nil)}.to raise_error(ArgumentError, /\AParameter should be \w+\z/)
    end

    it "should check required parameter" do
      expect {client.query_trade_info({
        MerchantTradeNo: "TS20160622800001"
      })}.to raise_error(ArgumentError, /\AMissing required parameter: \w+\z/)
    end

    it "should return trade information" do
      result = client.query_trade_info(
        ServiceURL: "https://payment-stage.allpay.com.tw/Cashier/QueryTradeInfo/V2",
        MerchantTradeNo: "TS20160622800001"
      )

      expect(result).to be_a(Hash)
    end
  end

  describe ".query_credit_card_period_info" do
    it "should check parameter type" do
      expect {client.query_credit_card_period_info(nil)}.to raise_error(ArgumentError, /\AParameter should be \w+\z/)
    end

    it "should check required parameter" do
      expect {client.query_credit_card_period_info({
        MerchantTradeNo: "TS20160622800003"
      })}.to raise_error(ArgumentError, /\AMissing required parameter: \w+\z/)
    end

    it "should return credit card period information" do
      result = client.query_credit_card_period_info({
        ServiceURL: "https://payment-stage.allpay.com.tw/Cashier/QueryCreditCardPeriodInfo",
        MerchantTradeNo: "TS20160622800003"
      })

      expect(result).to be_a(Hash)
      expect(result).to have_key("MerchantID")
      expect(result["MerchantID"]).to eq(client.merchant_id)
      expect(result).to have_key("MerchantTradeNo")
      expect(result["MerchantTradeNo"]).to eq("TS20160622800003")
      expect(result).to have_key("TradeNo")
      expect(result).to have_key("RtnCode")
      expect(result).to have_key("PeriodType")
      expect(result).to have_key("Frequency")
      expect(result).to have_key("ExecTimes")
      expect(result).to have_key("PeriodAmount")
      expect(result).to have_key("amount")
      expect(result).to have_key("gwsr")
      expect(result).to have_key("process_date")
      expect(result).to have_key("auth_code")
      expect(result).to have_key("card4no")
      expect(result).to have_key("card6no")
      expect(result).to have_key("TotalSuccessTimes")
      expect(result).to have_key("TotalSuccessAmount")
      expect(result).to have_key("ExecLog")
      expect(result).to have_key("ExecStatus")
    end
  end

  describe ".do_action" do
    it "should check parameter type" do
      expect {client.do_action(nil)}.to raise_error(ArgumentError, /\AParameter should be \w+\z/)
    end

    it "should check required parameter" do
      expect {client.do_action({
        MerchantTradeNo: "T20160622800001",
        TradeNo: "1606221340479404",
        Action: Allpay::ActionType::N,
        TotalAmount: 200
      })}.to raise_error(ArgumentError, /\AMissing required parameter: \w+\z/)
    end

    it "should check parameter value" do
      expect {client.do_action({
        ServiceURL: "https://payment-stage.allpay.com.tw/CreditDetail/DoAction",
        MerchantTradeNo: "T20160622800001",
        TradeNo: "1606221340479404",
        Action: "X",
        TotalAmount: 200
      })}.to raise_error(ArgumentError, /\A\w+ should be .+\z/)
    end

    it "should return action result" do
      result = client.do_action({
        ServiceURL: "https://payment-stage.allpay.com.tw/CreditDetail/DoAction",
        MerchantTradeNo: "T20160622800001",
        TradeNo: "1606221340479404",
        Action: Allpay::ActionType::N,
        TotalAmount: 200
      })

      expect(result).to be_a(Hash)
      expect(result).to have_key("Merchant")
      expect(result["Merchant"]).to eq(client.merchant_id)
      expect(result).to have_key("MerchantTradeNo")
      expect(result["MerchantTradeNo"]).to eq("T20160622800001")
      expect(result).to have_key("TradeNo")
      expect(result).to have_key("RtnCode")
      expect(result).to have_key("RtnMsg")
    end
  end

  describe ".aio_chargeback" do
    it "should check parameter type" do
      expect {client.aio_chargeback(nil)}.to raise_error(ArgumentError, /\AParameter should be \w+\z/)
    end

    it "should check required parameter" do
      expect {client.aio_chargeback({
        MerchantTradeNo: "TS20160622800004",
        TradeNo: "1606220912379642",
        ChargeBackTotalAmount: 500
      })}.to raise_error(ArgumentError, /\AMissing required parameter: \w+\z/)
    end

    it "should return charge back information" do
      skip("Only return OK at first time")
      result = client.aio_chargeback({
        ServiceURL: "https://payment-stage.allpay.com.tw//Cashier/AioChargeback",
        MerchantTradeNo: "TS20160622800004",
        TradeNo: "1606220912379642",
        ChargeBackTotalAmount: 500
      })

      expect(result).to be_a(Hash)
      expect(result).to have_key("RtnCode")
      expect(result["RtnCode"]).to eq("1")
      expect(result).to have_key("RtnMsg")
      expect(result["RtnCode"]).to eq("OK")
    end
  end

  describe ".capture" do
    it "should check parameter type" do
      expect {client.capture(nil)}.to raise_error(ArgumentError, /\AParameter should be \w+\z/)
    end

    it "should check required parameter" do
      expect {client.capture({
        MerchantTradeNo: "TS20160622800005",
        CaptureAMT: 30,
        UserRefundAMT: 270,
        UserName: "王大明",
        UserCellPhone: "0987654321"
      })}.to raise_error(ArgumentError, /\AMissing required parameter: \w+\z/)
    end

    it "should return capture information" do
      result = client.capture({
        ServiceURL: "https://payment-stage.allpay.com.tw/Cashier/Capture",
        MerchantTradeNo: "TS20160622800005",
        CaptureAMT: 30,
        UserRefundAMT: 270,
        UserName: "王大明",
        UserCellPhone: "0987654321"
      })

      expect(result).to have_key("MerchantID")
      expect(result["MerchantID"]).to eq(client.merchant_id)
      expect(result).to have_key("MerchantTradeNo")
      expect(result["MerchantTradeNo"]).to eq("TS20160622800005")
      expect(result).to have_key("TradeNo")
      expect(result).to have_key("RtnCode")
      expect(result).to have_key("RtnMsg")
      expect(result).to have_key("AllocationDate")
    end
  end

  describe ".download_aio_payment_media" do
    before(:all) do
      tmp_dir = "#{Dir.pwd}/tmp"
      Dir.mkdir tmp_dir unless Dir.exists? tmp_dir

      @new_version_csv_path = "#{tmp_dir}/new.csv"
      @old_version_csv_path = "#{tmp_dir}/old.csv"
    end

    after(:all) do
      FileUtils.rm(@new_version_csv_path) if File.exists? @new_version_csv_path
      FileUtils.rm(@old_version_csv_path) if File.exists? @old_version_csv_path
    end

    it "should check parameter type" do
      expect {client.download_aio_payment_media(nil)}.to raise_error(ArgumentError, /\AParameter should be \w+\z/)
    end

    it "should check required parameter" do
      expect {client.download_aio_payment_media({
        DateType: Allpay::TradeDateType::PAYMENT,
        BeginDate: "2016-06-22",
        EndDate: "2016-06-22",
        MediaFormated: Allpay::MediaFormat::NEW,
        FilePath: @new_version_csv_path
      })}.to raise_error(ArgumentError, /\AMissing required parameter: \w+\z/)
    end

    it "should check parameter format" do
      expect {client.download_aio_payment_media({
        ServiceURL: "https://vendor-stage.allpay.com.tw/PaymentMedia/TradeNoAio",
        DateType: Allpay::TradeDateType::PAYMENT,
        BeginDate: "2016/06/22",
        EndDate: "2016/06/22",
        MediaFormated: Allpay::MediaFormat::NEW,
        FilePath: @new_version_csv_path
      })}.to raise_error(ArgumentError, /\AThe format for \w+ is wrong\z/)
    end

    it "should download AIO payment media(old version)" do
      client.download_aio_payment_media({
        ServiceURL: "https://vendor-stage.allpay.com.tw/PaymentMedia/TradeNoAio",
        DateType: Allpay::TradeDateType::PAYMENT,
        BeginDate: "2016-06-22",
        EndDate: "2016-06-22",
        MediaFormated: Allpay::MediaFormat::OLD,
        FilePath: @old_version_csv_path
      })
      header = "交易日期,歐付寶交易序號,特店訂單編號,ATM條碼,交易金額,付款方式,付款結果,付款日期,款項來源(銀行/超商),通路費,交易服務費率(%數 / $筆),交易服務費金額,應收款項(淨額),撥款狀態,撥款日期,備註"

      media_data = File.read(@old_version_csv_path)
      media_data.encode!("UTF-8", "Big5", invalid: :replace, undef: :replace, replace: "?") if media_data.encoding.name != "UTF-8"

      expect(media_data).to include(header)
    end

    it "should download AIO payment media(new version)" do
      client.download_aio_payment_media({
        ServiceURL: "https://vendor-stage.allpay.com.tw/PaymentMedia/TradeNoAio",
        DateType: Allpay::TradeDateType::PAYMENT,
        BeginDate: "2016-06-22",
        EndDate: "2016-06-22",
        MediaFormated: Allpay::MediaFormat::NEW,
        FilePath: @new_version_csv_path
      })
      header = '="訂單日期",="廠商訂單編號",="歐付寶訂單編號",="平台名稱",="付款方式",="費率(每筆)",="信用卡授權單號",="信用卡卡號末4碼",="超商資訊/ATM繳款帳號",="付款狀態",="交易金額",="退款日期",="退款金額",="交易手續費",="平台手續費",="應收款項(淨額)",="撥款狀態",="買家備註",="廠商備註"'

      media_data = File.read(@new_version_csv_path)
      media_data.encode!("UTF-8", "Big5", invalid: :replace, undef: :replace, replace: "?") if media_data.encoding.name != "UTF-8"

      expect(media_data).to include(header)
    end
  end

  describe ".gen_check_mac_value" do
    it "should check parameter type" do
      expect {client.gen_check_mac_value(nil)}.to raise_error(ArgumentError, /\AParameter should be \w+\z/)
    end

    it "should generate CheckMacValue by MD5" do
      check_mac_value = client.gen_check_mac_value({
        MerchantID: "2000214",
        MerchantTradeNo: "TS20160622800001",
        MerchantTradeDate: "2016/06/22 01:00:00",
        PaymentType: "aio",
        TotalAmount: 100,
        TradeDesc: "Hello World 網路商城",
        ItemName: "德國原裝進口自動鉛筆 60 元 x 1#橡皮擦 20 元 x 2",
        ReturnURL: "http://localhost/receive",
        ChoosePayment: Allpay::PaymentMethod::ALL
      })

      expect(check_mac_value).to eq("14CB214EF5271B870FC75F91329357C9")
    end

    it "should generate CheckMacValue by SHA256" do
      check_mac_value = client.gen_check_mac_value({
        MerchantID: "2000214",
        MerchantTradeNo: "TS20160622800001",
        MerchantTradeDate: "2016/06/22 01:00:00",
        PaymentType: "aio",
        TotalAmount: 100,
        TradeDesc: "Hello World 網路商城",
        EncryptType: Allpay::EncryptType::SHA256,
        ItemName: "德國原裝進口自動鉛筆 60 元 x 1#橡皮擦 20 元 x 2",
        ReturnURL: "http://localhost/receive",
        ChoosePayment: Allpay::PaymentMethod::ALL
      })

      expect(check_mac_value).to eq("C5FBAD71FC508663A280B59457520FA1F4D5254353DD23533653939046518BF8")
    end
  end
end
