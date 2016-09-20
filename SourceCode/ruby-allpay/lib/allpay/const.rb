module Allpay
  class Base
    def self.readable_keys
      result = self.constants.map { |constant| "#{self.name}::#{constant}" }.join(", ")
      position = result.rindex(", ")
      result[position..position+1] = " or "
      result
    end

    def self.values
      self.constants.map { |constant| self.const_get(constant) }
    end
  end

  # 呼叫服務的方法
  class HttpMethod < Base
    # 以 HTTP 的 GET 方法傳遞資料
    HTTP_GET = :GET
    # 以 HTTP 的 POST 方法傳遞資料
    HTTP_POST = :POST
  end

  # 付款方式
  class PaymentMethod < Base
    # 不指定付款方式
    ALL = "ALL"
    # 信用卡付費
    CREDIT = "Credit"
    # 網路 ATM
    WEB_ATM = "WebATM"
    # 自動櫃員機
    ATM = "ATM"
    # 超商代碼
    CVS = "CVS"
    # 超商條碼
    BARCODE = "BARCODE"
    # 財付通
    TENPAY = "Tenpay"
    # 儲值消費
    TOP_UP_USED = "TopUpUsed"
  end

  # 付款方式子項目
  class PaymentMethodItem < Base
    # 不指定
    NONE = ""
    #########################
    # WebATM 類(001~100)
    #########################
    # 台新銀行
    WEB_ATM_TAISHIN = "TAISHIN"
    # 玉山銀行
    WEB_ATM_ESUN = "ESUN"
    # 華南銀行
    WEB_ATM_HUANAN = "HUANAN"
    # 台灣銀行
    WEB_ATM_BOT = "BOT"
    # 台北富邦
    WEB_ATM_FUBON = "FUBON"
    # 中國信託
    WEB_ATM_CHINATRUST = "CHINATRUST"
    # 第一銀行
    WEB_ATM_FIRST = "FIRST"
    # 國泰世華
    WEB_ATM_CATHAY = "CATHAY"
    # 兆豐銀行
    WEB_ATM_MEGA = "MEGA"
    # 元大銀行
    WEB_ATM_YUANTA = "YUANTA"
    # 土地銀行
    WEB_ATM_LAND = "LAND"
    #########################
    # ATM 類(101~200)
    #########################
    # 台新銀行
    ATM_TAISHIN = "TAISHIN"
    # 玉山銀行
    ATM_ESUN = "ESUN"
    # 華南銀行
    ATM_HUANAN = "HUANAN"
    # 台灣銀行
    ATM_BOT = "BOT"
    # 台北富邦
    ATM_FUBON = "FUBON"
    # 中國信託
    ATM_CHINATRUST = "CHINATRUST"
    # 第一銀行
    ATM_FIRST = "FIRST"
    # 土地銀行
    ATM_LAND = "LAND"
    # 國泰世華銀行
    ATM_CATHAY = "CATHAY"
    # 大眾銀行
    ATM_Tachong = "Tachong"
    # 永豐銀行
    ATM_Sinopac = "Sinopac"
    # 彰化銀行
    ATM_CHB = "CHB"
    #########################
    # 超商類(201~300)
    #########################
    # 超商代碼繳款
    CVS = "CVS"
    # OK超商代碼繳款
    CVS_OK = "OK"
    # 全家超商代碼繳款
    CVS_FAMILY = "FAMILY"
    # 萊爾富超商代碼繳款
    CVS_HILIFE = "HILIFE"
    # 7-11 ibon代碼繳款
    CVS_IBON = "IBON"
    #########################
    # 其他第三方支付類(301~400)
    #########################
    # 財付通
    TENPAY = "Tenpay"
    #########################
    # 儲值/餘額消費類(401~500)
    #########################
    # 儲值/餘額消費(歐付寶)
    TOP_UP_USED_ALLPAY = "AllPay"
    # 儲值/餘額消費(玉山)
    TOP_UP_USED_ESUN = "ESUN"
    #########################
    # 其他類(901~999)
    #########################
    # 超商條碼繳款
    BARCODE = "BARCODE"
    # 信用卡(MasterCard/JCB/VISA)
    CREDIT = "Credit"
  end

  # 額外付款資訊
  class ExtraPaymentInfo < Base
    # 需要額外付款資訊
    YES = "Y"
    # 不需要額外付款資訊
    NO = "N"
  end

  # 裝置類型
  class DeviceType < Base
    # 桌機版付費頁面
    PC = "P"
    # 行動裝置版付費頁面
    MOBILE = "M"
  end

  # 信用卡訂單處理動作資訊
  class ActionType < Base
    # 關帳
    C = "C"
    # 退刷
    R = "R"
    # 取消
    E = "E"
    # 放棄
    N = "N"
  end

  # 定期定額的週期種類
  class PeriodType < Base
    # 日
    DAY = "D"
    # 月
    MONTH = "M"
    # 年
    YEAR = "Y"
  end

  # 電子發票開立註記
  class InvoiceMark < Base
    # 需要開立電子發票
    YES = "Y"
    # 不需要開立電子發票
    NO = ""
  end

  # 電子發票載具類別
  class CarrierType < Base
    # 無載具
    NONE = ""
    # 會員載具
    MEMBER = "1"
    # 買受人自然人憑證
    CITIZEN = "2"
    # 買受人手機條碼
    CELLPHONE = "3"
  end

  # 電子發票列印註記
  class PrintMark < Base
    # 列印
    YES = "1"
    # 不列印
    NO = "0"
  end

  # 電子發票捐贈註記
  class Donation < Base
    # 捐贈
    YES = "1"
    # 不捐贈
    NO = "2"
  end

  # 通關方式
  class ClearanceMark < Base
    # 經海關出口
    YES = "1"
    # 非經海關出口
    NO = "2"
  end

  # 課稅類別
  class TaxType < Base
    # 應稅
    DUTIABLE = "1"
    # 零稅率
    ZERO = "2"
    # 免稅
    FREE = "3"
    # 應稅與免稅混合(限收銀機發票無法分辦時使用，且需通過申請核可)
    MIX = "9"
  end

  # 字軌類別
  class InvType < Base
    # 一般稅額
    GENERAL = "07"
    # 特種稅額
    SPECIAL = "08"
  end

  # 加密類型
  class EncryptType < Base
    # MD5(預設)
    MD5 = 0
    # SHA256
    SHA256 = 1
  end

  # 購物金/紅利折抵
  class UseRedeem < Base
    # 使用紅利/購物金
    YES = "Y"
    # 不使用紅利/購物金
    NO = "N"
  end

  # 查詢日期類型
  class TradeDateType < Base
    # 付款日期
    PAYMENT = "2"
    # 撥款日期
    APPROPRIATION = "4"
    # 退款日期
    REFUND = "5"
    # 訂單日期
    ORDER = "6"
  end

  # 付款方式
  class PaymentType < Base
    # 全部
    ALL = "0"
    # 信用卡付費
    CREDIT = "01"
    # 網路 ATM
    WEB_ATM = "02"
    # 自動櫃員機
    ATM = "03"
    # 超商代碼
    CVS = "04"
    # 超商條碼
    BARCODE = "05"
    # 財付通
    TENPAY = "07"
    # 信用卡付費(OTP)
    CREDIT_OTP = "08"
    # 儲值消費
    TOP_UP_USED = "09"
    # 全家條碼立即儲
    FAMISAVE = "10"
  end

  # 訂單類型
  class PlatformStatus < Base
    # 全部
    ALL = "0"
    # 一般
    GENERAL = "1"
    # 平台商
    PLATFORM = "2"
  end

  # 付款狀態
  class PaymentStatus < Base
    # 全部
    ALL = "9"
    # 未付款
    NON_PAYMENT = "0"
    # 已付款
    PAID = "1"
    # 訂單失敗
    FAIL = "2"
  end

  # 撥款狀態
  class AllocateStatus < Base
    # 全部
    ALL = "9"
    # 未撥款
    NO_APPROPRIATIONS = "0"
    # 已撥款
    APPROPRIATIONS = "1"
  end

  # 媒體檔格式
  class MediaFormat < Base
    # 舊版格式
    OLD = "0"
    # 新版格式
    NEW = "1"
  end

  # 延遲撥款
  class HoldTradeType < Base
    # 不要延遲撥款
    NO = 0
    # 要延遲撥款
    YES = 1
  end

  # 銀聯卡交易
  class UnionPay < Base
    # 不是銀聯卡交易
    NO = 0
    # 是銀聯卡交易
    YES = 1
  end
end
