require "digest"
require "uri"
require "net/http"
require "net/https"
require "json"
require "allpay/core_ext/hash"
require "allpay/core_ext/string"

module Allpay
  class ErrorMessage
    def self.generate params
      case params[:msg]
      when :missing_parameter
        "Missing required parameter: #{params[:field]}"
      when :parameter_should_be
        "#{params[:field]} should be #{params[:data]}"
      when :parameter_cannot_be
        "#{params[:field]} cannot be #{params[:data]}"
      when :reach_max_length
        "The maximum length for #{params[:field]} is #{params[:length]}"
      when :fixed_length
        "The length for #{params[:field]} should be #{params[:length]}"
      when :wrong_data_format
        "The format for #{params[:field]} is wrong"
      when :remove_parameter
        "Please remove #{params[:field]}"
      when :cannot_be_empty
        "#{params[:field]} cannot be empty"
      when :check_mac_value_verify_fail
        "CheckMacValue verify fail"
      end
    end
  end

  class Client
    attr_accessor :merchant_id, :hash_key, :hash_iv

    # 建構子
    def initialize merchant_id:, hash_key:, hash_iv:
      raise_argument_error(msg: :missing_parameter, field: :merchant_id) if merchant_id.nil?
      raise_argument_error(msg: :parameter_should_be, field: :merchant_id, data: "String") unless merchant_id.is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :merchant_id) if merchant_id.empty?
      raise_argument_error(msg: :reach_max_length, field: :merchant_id, length: 10) if merchant_id.size > 10

      raise_argument_error(msg: :missing_parameter, field: :hash_key) if hash_key.nil?
      raise_argument_error(msg: :parameter_should_be, field: :hash_key, data: "String") unless hash_key.is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :hash_key) if hash_key.empty?

      raise_argument_error(msg: :missing_parameter, field: :hash_iv) if hash_iv.nil?
      raise_argument_error(msg: :parameter_should_be, field: :hash_iv, data: "String") unless hash_iv.is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :hash_iv) if hash_iv.empty?

      @merchant_id = merchant_id
      @hash_key = hash_key
      @hash_iv = hash_iv
    end

    # 訂單產生
    def aio_check_out params = {}
      raise_argument_error(msg: :parameter_should_be, field: "Parameter", data: "Hash") unless params.is_a? Hash

      raise_argument_error(msg: :missing_parameter, field: :ServiceURL) if params[:ServiceURL].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ServiceURL, data: "String") unless params[:ServiceURL].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :ServiceURL) if params[:ServiceURL].empty?

      raise_argument_error(msg: :missing_parameter, field: :MerchantTradeNo) if params[:MerchantTradeNo].nil?
      raise_argument_error(msg: :parameter_should_be, field: :MerchantTradeNo, data: "String") unless params[:MerchantTradeNo].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :MerchantTradeNo) if params[:MerchantTradeNo].empty?
      raise_argument_error(msg: :reach_max_length, field: :MerchantTradeNo, length: 20) if params[:MerchantTradeNo].size > 20

      raise_argument_error(msg: :missing_parameter, field: :MerchantTradeDate) if params[:MerchantTradeDate].nil?
      raise_argument_error(msg: :parameter_should_be, field: :MerchantTradeDate, data: "String") unless params[:MerchantTradeDate].is_a? String
      raise_argument_error(msg: :wrong_data_format, field: :MerchantTradeDate) unless /\A\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}\z/.match(params[:MerchantTradeDate])

      # NOTE: 目前預設自動帶入 aio
      # raise_argument_error(msg: :missing_parameter, field: :PaymentType) if params[:PaymentType].nil?
      # raise_argument_error(msg: :parameter_should_be, field: :PaymentType, data: "String") unless params[:PaymentType].is_a? String
      # raise_argument_error(msg: :cannot_be_empty, field: :PaymentType) if params[:PaymentType].empty?
      # raise_argument_error(msg: :reach_max_length, field: :PaymentType, length: 20) if params[:PaymentType].size > 20

      raise_argument_error(msg: :missing_parameter, field: :TotalAmount) if params[:TotalAmount].nil?
      raise_argument_error(msg: :parameter_should_be, field: :TotalAmount, data: "Integer") unless params[:TotalAmount].is_a? Integer
      raise_argument_error(msg: :parameter_should_be, field: :TotalAmount, data: "greater than 0") if params[:TotalAmount] <= 0

      raise_argument_error(msg: :missing_parameter, field: :TradeDesc) if params[:TradeDesc].nil?
      raise_argument_error(msg: :parameter_should_be, field: :TradeDesc, data: "String") unless params[:TradeDesc].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :TradeDesc) if params[:TradeDesc].empty?
      raise_argument_error(msg: :reach_max_length, field: :TradeDesc, length: 200) if params[:TradeDesc].size > 200

      raise_argument_error(msg: :missing_parameter, field: :Items) if params[:Items].nil?
      raise_argument_error(msg: :parameter_should_be, field: :Items, data: "Array") unless params[:Items].is_a? Array
      raise_argument_error(msg: :cannot_be_empty, field: :Items) if params[:Items].empty?

      params[:Items].each do |item|
        raise_argument_error(msg: :missing_parameter, field: "Items.name") if item[:name].nil?
        raise_argument_error(msg: :parameter_should_be, field: "Items.name", data: "String") unless item[:name].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: "Items.name") if item[:name].empty?

        raise_argument_error(msg: :missing_parameter, field: "Items.price") if item[:price].nil?
        raise_argument_error(msg: :parameter_should_be, field: "Items.price", data: "Integer") unless item[:price].is_a? Integer
        raise_argument_error(msg: :parameter_should_be, field: "Items.price", data: "greater than 0") if item[:price] <= 0

        raise_argument_error(msg: :missing_parameter, field: "Items.currency") if item[:currency].nil?
        raise_argument_error(msg: :parameter_should_be, field: "Items.currency", data: "String") unless item[:currency].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: "Items.currency") if item[:currency].empty?

        raise_argument_error(msg: :missing_parameter, field: "Items.quantity") if item[:quantity].nil?
        raise_argument_error(msg: :parameter_should_be, field: "Items.quantity", data: "Integer") unless item[:quantity].is_a? Integer
        raise_argument_error(msg: :parameter_should_be, field: "Items.quantity", data: "greater than 0") if item[:quantity] <= 0
      end

      raise_argument_error(msg: :missing_parameter, field: :ReturnURL) if params[:ReturnURL].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ReturnURL, data: "String") unless params[:ReturnURL].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :ReturnURL) if params[:ReturnURL].empty?
      raise_argument_error(msg: :reach_max_length, field: :ReturnURL, length: 200) if params[:ReturnURL].size > 200

      raise_argument_error(msg: :missing_parameter, field: :ChoosePayment) if params[:ChoosePayment].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ChoosePayment, data: "String") unless params[:ChoosePayment].is_a? String
      raise_argument_error(msg: :parameter_should_be, field: :ChoosePayment, data: PaymentMethod.readable_keys) unless PaymentMethod.values.include? params[:ChoosePayment]

      # NOTE: 目前由 API 檢查最低金額
      # if [PaymentMethod::CVS, PaymentMethod::BARCODE].include? params[:ChoosePayment] and params[:TotalAmount] < 30
      #   raise_argument_error(msg: :parameter_should_be, field: :TotalAmount, data: "greater than or equal to 30")
      # end

      if params.has_key? :ClientBackURL
        raise_argument_error(msg: :parameter_should_be, field: :ClientBackURL, data: "String") unless params[:ClientBackURL].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :ClientBackURL, length: 200) if params[:ClientBackURL].size > 200
      end

      if params.has_key? :ItemURL
        raise_argument_error(msg: :parameter_should_be, field: :ItemURL, data: "String") unless params[:ItemURL].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :ItemURL, length: 200) if params[:ItemURL].size > 200
      end

      if params.has_key? :Remark
        raise_argument_error(msg: :parameter_should_be, field: :Remark, data: "String") unless params[:Remark].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :Remark, length: 100) if params[:Remark].size > 100
      end

      if params.has_key? :ChooseSubPayment
        raise_argument_error(msg: :parameter_should_be, field: :ChooseSubPayment, data: "String") unless params[:ChooseSubPayment].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :ChooseSubPayment, data: PaymentMethodItem.readable_keys) unless PaymentMethodItem.values.include? params[:ChooseSubPayment]
      end

      if params.has_key? :OrderResultURL
        raise_argument_error(msg: :parameter_should_be, field: :OrderResultURL, data: "String") unless params[:OrderResultURL].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :OrderResultURL, length: 200) if params[:OrderResultURL].size > 200
      end

      if params.has_key? :NeedExtraPaidInfo
        raise_argument_error(msg: :parameter_should_be, field: :NeedExtraPaidInfo, data: "String") unless params[:NeedExtraPaidInfo].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :NeedExtraPaidInfo, data: ExtraPaymentInfo.readable_keys) unless ExtraPaymentInfo.values.include? params[:NeedExtraPaidInfo]
      end

      if params.has_key? :DeviceSource
        raise_argument_error(msg: :parameter_should_be, field: :DeviceSource, data: "String") unless params[:DeviceSource].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :DeviceSource, data: DeviceType.readable_keys) unless DeviceType.values.include? params[:DeviceSource]

        if params[:DeviceSource] == DeviceType::MOBILE and params[:ChoosePayment] != PaymentMethod::ALL
          raise_argument_error(msg: :parameter_should_be, field: :DeviceSource, data: "Allpay::DeviceType::PC or change ChoosePayment to Allpay::PaymentMethod::ALL")
        end
      end

      if params.has_key? :IgnorePayment
        raise_argument_error(msg: :parameter_should_be, field: :IgnorePayment, data: "String") unless params[:IgnorePayment].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :IgnorePayment, length: 100) if params[:IgnorePayment].size > 100

        ignore_payments = params[:IgnorePayment].split("#")
        valid_options = Allpay::PaymentMethod.values
        valid_options.delete "ALL"
        options_for_message = Allpay::PaymentMethod.readable_keys
        options_for_message["Allpay::PaymentMethod::ALL, "] = ""

        if (ignore_payments - valid_options).size != 0
          raise_argument_error(msg: :parameter_should_be, field: :IgnorePayment, data: options_for_message)
        end

        if ignore_payments.size > 0 and params[:ChoosePayment] != PaymentMethod::ALL
          raise_argument_error(msg: :parameter_should_be, field: :ChoosePayment, data: "Allpay::PaymentMethod::ALL or remove IgnorePayment")
        end
      end

      if params.has_key? :PlatformID
        raise_argument_error(msg: :parameter_should_be, field: :PlatformID, data: "String") unless params[:PlatformID].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :PlatformID, length: 10) if params[:PlatformID].size > 10
      end

      if params.has_key? :InvoiceMark
        raise_argument_error(msg: :parameter_should_be, field: :InvoiceMark, data: "String") unless params[:InvoiceMark].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :InvoiceMark, data: InvoiceMark.readable_keys) unless InvoiceMark.values.include? params[:InvoiceMark]
      end

      if params.has_key? :HoldTradeAMT
        raise_argument_error(msg: :parameter_should_be, field: :HoldTradeAMT, data: "Integer") unless params[:HoldTradeAMT].is_a? Integer
        raise_argument_error(msg: :parameter_should_be, field: :HoldTradeAMT, data: HoldTradeType.readable_keys) unless HoldTradeType.values.include? params[:HoldTradeAMT]

        if [PaymentMethod::CREDIT, PaymentMethod::TENPAY].include? params[:ChoosePayment]
          raise_argument_error(msg: :remove_parameter, field: :HoldTradeAMT)
        end
      end

      if params.has_key? :EncryptType
        raise_argument_error(msg: :parameter_should_be, field: :EncryptType, data: "Integer") unless params[:EncryptType].is_a? Integer
        raise_argument_error(msg: :parameter_should_be, field: :EncryptType, data: EncryptType.readable_keys) unless EncryptType.values.include? params[:EncryptType]
      end

      if params.has_key? :UseRedeem
        raise_argument_error(msg: :parameter_should_be, field: :UseRedeem, data: "String") unless params[:UseRedeem].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :UseRedeem, data: UseRedeem.readable_keys) unless UseRedeem.values.include? params[:UseRedeem]
      end

      if [PaymentMethod::ATM, PaymentMethod::CVS, PaymentMethod::BARCODE].include? params[:ChoosePayment]
        if params[:ChoosePayment] == PaymentMethod::ATM
          if params.has_key? :ExpireDate
            raise_argument_error(msg: :parameter_should_be, field: :ExpireDate, data: "Integer") unless params[:ExpireDate].is_a? Integer

            if params[:ExpireDate] < 1 or params[:ExpireDate] > 60
              raise_argument_error(msg: :parameter_should_be, field: :ExpireDate, data: "1 ~ 60")
            end
          end

          raise_argument_error(msg: :missing_parameter, field: :PaymentInfoURL) if params[:PaymentInfoURL].nil?
          raise_argument_error(msg: :parameter_should_be, field: :PaymentInfoURL, data: "String") unless params[:PaymentInfoURL].is_a? String
          raise_argument_error(msg: :cannot_be_empty, field: :PaymentInfoURL) if params[:PaymentInfoURL].empty?
          raise_argument_error(msg: :reach_max_length, field: :PaymentInfoURL, length: 200) if params[:PaymentInfoURL].size > 200
        else
          if params.has_key? :StoreExpireDate
            raise_argument_error(msg: :parameter_should_be, field: :StoreExpireDate, data: "Integer") unless params[:StoreExpireDate].is_a? Integer
            raise_argument_error(msg: :parameter_should_be, field: :StoreExpireDate, data: "greater than 0") if params[:StoreExpireDate] <= 0
          end

          if params.has_key? :Desc_1
            raise_argument_error(msg: :parameter_should_be, field: :Desc_1, data: "String") unless params[:Desc_1].is_a? String
            raise_argument_error(msg: :reach_max_length, field: :Desc_1, length: 20) if params[:Desc_1].size > 20
          end

          if params.has_key? :Desc_2
            raise_argument_error(msg: :parameter_should_be, field: :Desc_2, data: "String") unless params[:Desc_2].is_a? String
            raise_argument_error(msg: :reach_max_length, field: :Desc_2, length: 20) if params[:Desc_2].size > 20
          end

          if params.has_key? :Desc_3
            raise_argument_error(msg: :parameter_should_be, field: :Desc_3, data: "String") unless params[:Desc_3].is_a? String
            raise_argument_error(msg: :reach_max_length, field: :Desc_3, length: 20) if params[:Desc_3].size > 20
          end

          if params.has_key? :Desc_4
            raise_argument_error(msg: :parameter_should_be, field: :Desc_4, data: "String") unless params[:Desc_4].is_a? String
            raise_argument_error(msg: :reach_max_length, field: :Desc_4, length: 20) if params[:Desc_4].size > 20
          end

          if params.has_key? :PaymentInfoURL
            raise_argument_error(msg: :parameter_should_be, field: :PaymentInfoURL, data: "String") unless params[:PaymentInfoURL].is_a? String
            raise_argument_error(msg: :reach_max_length, field: :PaymentInfoURL, length: 200) if params[:PaymentInfoURL].size > 200
          end
        end

        if params.has_key? :ClientRedirectURL
          raise_argument_error(msg: :parameter_should_be, field: :ClientRedirectURL, data: "String") unless params[:ClientRedirectURL].is_a? String
          raise_argument_error(msg: :reach_max_length, field: :ClientRedirectURL, length: 200) if params[:ClientRedirectURL].size > 200
        end
      end

      if params[:ChoosePayment] == PaymentMethod::TENPAY
        if params.has_key? :ExpireTime
          raise_argument_error(msg: :parameter_should_be, field: :ExpireTime, data: "String") unless params[:ExpireTime].is_a? String
          raise_argument_error(msg: :wrong_data_format, field: :ExpireTime) unless /\A\d{4}\/\d{2}\/\d{2} \d{2}:\d{2}:\d{2}\z/.match(params[:ExpireTime])
        end
      end

      if params[:ChoosePayment] == PaymentMethod::CREDIT
        if params.has_key? :CreditInstallment
          raise_argument_error(msg: :parameter_should_be, field: :CreditInstallment, data: "Integer") unless params[:CreditInstallment].is_a? Integer
          raise_argument_error(msg: :parameter_should_be, field: :CreditInstallment, data: "greater than or equal to 0") if params[:CreditInstallment] < 0
          raise_argument_error(msg: :missing_parameter, field: :InstallmentAmount) if params[:InstallmentAmount].nil?
        end

        if params.has_key? :InstallmentAmount
          raise_argument_error(msg: :missing_parameter, field: :CreditInstallment) if params[:CreditInstallment].nil?
          raise_argument_error(msg: :parameter_should_be, field: :InstallmentAmount, data: "Integer") unless params[:InstallmentAmount].is_a? Integer
          raise_argument_error(msg: :parameter_should_be, field: :InstallmentAmount, data: "greater than or equal to 0") if params[:InstallmentAmount] < 0
          raise_argument_error(msg: :parameter_should_be, field: :CreditInstallment, data: "greater than 0") if params[:InstallmentAmount] > 0 and params[:CreditInstallment] == 0
        end

        if params.has_key? :Redeem
          raise_argument_error(msg: :parameter_should_be, field: :Redeem, data: "String") unless params[:Redeem].is_a? String
          raise_argument_error(msg: :reach_max_length, field: :Redeem, length: 1) if params[:Redeem].size > 1
        end

        if params.has_key? :UnionPay
          raise_argument_error(msg: :parameter_should_be, field: :UnionPay, data: "Integer") unless params[:UnionPay].is_a? Integer
          raise_argument_error(msg: :parameter_should_be, field: :UnionPay, data: UnionPay.readable_keys) unless UnionPay.values.include? params[:UnionPay]
        end

        if params.has_key? :Language
          raise_argument_error(msg: :parameter_should_be, field: :Language, data: "String") unless params[:Language].is_a? String
          raise_argument_error(msg: :reach_max_length, field: :Language, length: 3) if params[:Language].size > 3
        end

        if params.has_key? :PeriodAmount
          raise_argument_error(msg: :parameter_should_be, field: :PeriodAmount, data: "Integer") unless params[:PeriodAmount].is_a? Integer
          raise_argument_error(msg: :parameter_should_be, field: :PeriodAmount, data: "equal to TotalAmount") if params[:PeriodAmount] != params[:TotalAmount]

          raise_argument_error(msg: :missing_parameter, field: :PeriodType) if params[:PeriodType].nil?
          raise_argument_error(msg: :missing_parameter, field: :Frequency) if params[:Frequency].nil?
          raise_argument_error(msg: :missing_parameter, field: :ExecTimes) if params[:ExecTimes].nil?
        end

        if params.has_key? :PeriodType
          raise_argument_error(msg: :missing_parameter, field: :PeriodAmount) if params[:PeriodAmount].nil?
          raise_argument_error(msg: :parameter_should_be, field: :PeriodType, data: "String") unless params[:PeriodType].is_a? String
          raise_argument_error(msg: :parameter_should_be, field: :PeriodType, data: PeriodType.readable_keys) unless PeriodType.values.include? params[:PeriodType]
        end

        if params.has_key? :Frequency
          raise_argument_error(msg: :missing_parameter, field: :PeriodAmount) if params[:PeriodAmount].nil?
          raise_argument_error(msg: :parameter_should_be, field: :Frequency, data: "Integer") unless params[:Frequency].is_a? Integer
          raise_argument_error(msg: :parameter_should_be, field: :Frequency, data: "greater than or equal to 1") if params[:Frequency] < 1

          if params[:PeriodType] == PeriodType::DAY
            raise_argument_error(msg: :parameter_should_be, field: :Frequency, data: "1 ~ 365") if params[:Frequency] > 365
          elsif params[:PeriodType] == PeriodType::MONTH
            raise_argument_error(msg: :parameter_should_be, field: :Frequency, data: "1 ~ 12") if params[:Frequency] > 12
          else
            raise_argument_error(msg: :parameter_should_be, field: :Frequency, data: "1") if params[:Frequency] > 1
          end
        end

        if params.has_key? :ExecTimes
          raise_argument_error(msg: :missing_parameter, field: :PeriodAmount) if params[:PeriodAmount].nil?
          raise_argument_error(msg: :parameter_should_be, field: :ExecTimes, data: "Integer") unless params[:ExecTimes].is_a? Integer
          raise_argument_error(msg: :parameter_should_be, field: :ExecTimes, data: "greater than or equal to 2") if params[:ExecTimes] < 2

          if params[:PeriodType] == PeriodType::DAY
            raise_argument_error(msg: :parameter_should_be, field: :ExecTimes, data: "2 ~ 999") if params[:ExecTimes] > 999
          elsif params[:PeriodType] == PeriodType::MONTH
            raise_argument_error(msg: :parameter_should_be, field: :ExecTimes, data: "2 ~ 99") if params[:ExecTimes] > 99
          else
            raise_argument_error(msg: :parameter_should_be, field: :ExecTimes, data: "2 ~ 9") if params[:ExecTimes] > 9
          end
        end

        if params.has_key? :PeriodReturnURL
          raise_argument_error(msg: :missing_parameter, field: :PeriodAmount) if params[:PeriodAmount].nil?
          raise_argument_error(msg: :parameter_should_be, field: :PeriodReturnURL, data: "String") unless params[:PeriodReturnURL].is_a? String
          raise_argument_error(msg: :reach_max_length, field: :PeriodReturnURL, length: 200) if params[:PeriodReturnURL].size > 200
        end
      end

      if params[:InvoiceMark] == InvoiceMark::YES
        raise_argument_error(msg: :missing_parameter, field: :RelateNumber) if params[:RelateNumber].nil?
        raise_argument_error(msg: :parameter_should_be, field: :RelateNumber, data: "String") unless params[:RelateNumber].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :RelateNumber) if params[:RelateNumber].empty?
        raise_argument_error(msg: :reach_max_length, field: :RelateNumber, length: 30) if params[:RelateNumber].size > 30

        if params.has_key? :CustomerIdentifier
          raise_argument_error(msg: :parameter_should_be, field: :CustomerIdentifier, data: "String") unless params[:CustomerIdentifier].is_a? String
          raise_argument_error(msg: :fixed_length, field: :CustomerIdentifier, length: 8) if params[:CustomerIdentifier] != "" and params[:CustomerIdentifier].size != 8
        end

        if params.has_key? :CarruerType
          raise_argument_error(msg: :parameter_should_be, field: :CarruerType, data: "String") unless params[:CarruerType].is_a? String
          raise_argument_error(msg: :parameter_should_be, field: :CarruerType, data: CarrierType.readable_keys) unless CarrierType.values.include? params[:CarruerType]

          if [CarrierType::MEMBER, Allpay::CarrierType::CITIZEN].include? params[:CarruerType]
            if params.has_key? :CustomerIdentifier and params[:CustomerIdentifier] != ""
              raise_argument_error(msg: :parameter_cannot_be, field: :CarruerType, data: "Allpay::CarrierType::MEMBER or Allpay::CarrierType::CITIZEN")
            end
          end
        end

        if params[:CarruerType] == CarrierType::MEMBER
          raise_argument_error(msg: :missing_parameter, field: :CustomerID) if params[:CustomerID].nil?
          raise_argument_error(msg: :parameter_should_be, field: :CustomerID, data: "String") unless params[:CustomerID].is_a? String
          raise_argument_error(msg: :cannot_be_empty, field: :CustomerID) if params[:CustomerID].empty?
          raise_argument_error(msg: :reach_max_length, field: :CustomerID, length: 20) if params[:CustomerID].size > 20
        end

        if params.has_key? :Donation
          raise_argument_error(msg: :parameter_should_be, field: :Donation, data: "String") unless params[:Donation].is_a? String
          raise_argument_error(msg: :parameter_should_be, field: :Donation, data: Donation.readable_keys) unless Donation.values.include? params[:Donation]

          if params[:Donation] == Donation::YES
            raise_argument_error(msg: :parameter_should_be, field: :Donation, data: "Allpay::Donation::NO") if params.has_key? :CustomerIdentifier and params[:CustomerIdentifier] != ""
          end
        end

        if params.has_key? :Print
          raise_argument_error(msg: :parameter_should_be, field: :Print, data: "String") unless params[:Print].is_a? String
          raise_argument_error(msg: :parameter_should_be, field: :Print, data: PrintMark.readable_keys) unless PrintMark.values.include? params[:Print]
        end

        raise_argument_error(msg: :parameter_should_be, field: :Print, data: "Allpay::PrintMark::NO") if params[:Donation] == Donation::YES and params[:Print] == PrintMark::YES

        if params.has_key? :CustomerIdentifier and params[:CustomerIdentifier] != ""
          if !params.has_key? :Print or params[:Print] == PrintMark::NO
            raise_argument_error(msg: :parameter_should_be, field: :Print, data: "Allpay::PrintMark::YES")
          end
        end

        if params[:Print] == PrintMark::YES
          raise_argument_error(msg: :missing_parameter, field: :CustomerName) if params[:CustomerName].nil?
          raise_argument_error(msg: :parameter_should_be, field: :CustomerName, data: "String") unless params[:CustomerName].is_a? String
          raise_argument_error(msg: :cannot_be_empty, field: :CustomerName) if params[:CustomerName].empty?
          raise_argument_error(msg: :reach_max_length, field: :CustomerName, length: 20) if params[:CustomerName].size > 20

          raise_argument_error(msg: :missing_parameter, field: :CustomerAddr) if params[:CustomerAddr].nil?
          raise_argument_error(msg: :parameter_should_be, field: :CustomerAddr, data: "String") unless params[:CustomerAddr].is_a? String
          raise_argument_error(msg: :cannot_be_empty, field: :CustomerAddr) if params[:CustomerAddr].empty?
          raise_argument_error(msg: :reach_max_length, field: :CustomerAddr, length: 200) if params[:CustomerAddr].size > 200
        end

        if !params.has_key? :CustomerPhone and !params.has_key? :CustomerEmail
          raise_argument_error(msg: :missing_parameter, field: "CustomerPhone or CustomerEmail")
        end

        if params.has_key? :CustomerPhone
          raise_argument_error(msg: :parameter_should_be, field: :CustomerPhone, data: "String") unless params[:CustomerPhone].is_a? String
          raise_argument_error(msg: :cannot_be_empty, field: :CustomerPhone) if !params.has_key?(:CustomerEmail) && params[:CustomerPhone].empty?
          raise_argument_error(msg: :reach_max_length, field: :CustomerPhone, length: 20) if params[:CustomerPhone].size > 20
        end

        if params.has_key? :CustomerEmail
          raise_argument_error(msg: :parameter_should_be, field: :CustomerEmail, data: "String") unless params[:CustomerEmail].is_a? String
          raise_argument_error(msg: :cannot_be_empty, field: :CustomerEmail) if !params.has_key?(:CustomerPhone) && params[:CustomerEmail].empty?
          raise_argument_error(msg: :reach_max_length, field: :CustomerEmail, length: 200) if params[:CustomerEmail].size > 200
        end

        raise_argument_error(msg: :missing_parameter, field: :TaxType) if params[:TaxType].nil?
        raise_argument_error(msg: :parameter_should_be, field: :TaxType, data: "String") unless params[:TaxType].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :TaxType, data: TaxType.readable_keys) unless TaxType.values.include? params[:TaxType]

        if params.has_key? :ClearanceMark
          raise_argument_error(msg: :parameter_should_be, field: :ClearanceMark, data: "String") unless params[:ClearanceMark].is_a? String
          raise_argument_error(msg: :parameter_should_be, field: :ClearanceMark, data: ClearanceMark.readable_keys) unless ClearanceMark.values.include? params[:ClearanceMark]
        elsif params[:TaxType] == TaxType::ZERO
          raise_argument_error(msg: :missing_parameter, field: :ClearanceMark)
        end

        if params.has_key? :CarruerNum
          raise_argument_error(msg: :parameter_should_be, field: :CarruerNum, data: "String") unless params[:CarruerNum].is_a? String
          raise_argument_error(msg: :reach_max_length, field: :CarruerNum, length: 64) if params[:CarruerNum].size > 64
        end

        case params[:CarruerType]
        when nil, CarrierType::NONE, CarrierType::MEMBER
          raise_argument_error(msg: :remove_parameter, field: :CarruerNum) if params.has_key? :CarruerNum and params[:CarruerNum] != ""
        when CarrierType::CITIZEN
          raise_argument_error(msg: :wrong_data_format, field: :CarruerNum) unless /\A[a-zA-Z]{2}\d{14}\z/.match(params[:CarruerNum])
        when CarrierType::CELLPHONE
          raise_argument_error(msg: :wrong_data_format, field: :CarruerNum) unless /\A\/{1}[0-9a-zA-Z+-.]{7}\z/.match(params[:CarruerNum])
        else
          raise_argument_error(msg: :remove_parameter, field: :CarruerNum)
        end

        if params[:Donation] == Donation::YES
          raise_argument_error(msg: :missing_parameter, field: :LoveCode) if params[:LoveCode].nil?
          raise_argument_error(msg: :parameter_should_be, field: :LoveCode, data: "String") unless params[:LoveCode].is_a? String
          raise_argument_error(msg: :wrong_data_format, field: :LoveCode) unless /\A([xX]{1}[0-9]{2,6}|[0-9]{3,7})\z/.match(params[:LoveCode])
        else
          raise_argument_error(msg: :remove_parameter, field: :LoveCode) if params.has_key? :LoveCode
        end

        raise_argument_error(msg: :missing_parameter, field: :InvoiceItems) if params[:InvoiceItems].nil?
        raise_argument_error(msg: :parameter_should_be, field: :InvoiceItems, data: "Array") unless params[:InvoiceItems].is_a? Array
        raise_argument_error(msg: :cannot_be_empty, field: :InvoiceItems) if params[:InvoiceItems].empty?

        params[:InvoiceItems].each do |invoice_items|
          raise_argument_error(msg: :missing_parameter, field: "InvoiceItems.name") if invoice_items[:name].nil?
          raise_argument_error(msg: :parameter_should_be, field: "InvoiceItems.name", data: "String") unless invoice_items[:name].is_a? String
          raise_argument_error(msg: :cannot_be_empty, field: "InvoiceItems.name") if invoice_items[:name].empty?

          raise_argument_error(msg: :missing_parameter, field: "InvoiceItems.count") if invoice_items[:count].nil?
          raise_argument_error(msg: :parameter_should_be, field: "InvoiceItems.count", data: "Integer") unless invoice_items[:count].is_a? Integer
          raise_argument_error(msg: :parameter_should_be, field: "InvoiceItems.count", data: "greater than 0") if invoice_items[:count] <= 0

          raise_argument_error(msg: :missing_parameter, field: "InvoiceItems.word") if invoice_items[:word].nil?
          raise_argument_error(msg: :parameter_should_be, field: "InvoiceItems.word", data: "String") unless invoice_items[:word].is_a? String
          raise_argument_error(msg: :cannot_be_empty, field: "InvoiceItems.word") if invoice_items[:word].empty?

          raise_argument_error(msg: :missing_parameter, field: "InvoiceItems.price") if invoice_items[:price].nil?
          raise_argument_error(msg: :parameter_should_be, field: "InvoiceItems.price", data: "Integer") unless invoice_items[:price].is_a? Integer
          raise_argument_error(msg: :parameter_should_be, field: "InvoiceItems.price", data: "greater than 0") if invoice_items[:price] <= 0

          raise_argument_error(msg: :missing_parameter, field: "InvoiceItems.taxType") if invoice_items[:taxType].nil?
          raise_argument_error(msg: :parameter_should_be, field: "InvoiceItems.taxType", data: "String") unless invoice_items[:taxType].is_a? String
          raise_argument_error(msg: :parameter_should_be, field: "InvoiceItems.taxType", data: TaxType.readable_keys) unless TaxType.values.include? invoice_items[:taxType]
        end

        if params.has_key? :DelayDay
          raise_argument_error(msg: :parameter_should_be, field: :DelayDay, data: "Integer") unless params[:DelayDay].is_a? Integer
          raise_argument_error(msg: :parameter_should_be, field: :DelayDay, data: "0 ~ 15") if params[:DelayDay] < 0 or params[:DelayDay] > 15
        end

        raise_argument_error(msg: :missing_parameter, field: :InvType) if params[:InvType].nil?
        raise_argument_error(msg: :parameter_should_be, field: :InvType, data: "String") unless params[:InvType].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :InvType, data: InvType.readable_keys) unless InvType.values.include? params[:InvType]
      end

      if params.has_key? :CheckMacValue
        raise_argument_error(msg: :parameter_should_be, field: :CheckMacValue, data: "String") unless params[:CheckMacValue].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :CheckMacValue) if params[:CheckMacValue].empty?
      end

      # 組合商品名稱
      items = []
      params[:Items].each do |item|
        items << "#{item[:name]} #{item[:price]} #{item[:currency]} x #{item[:quantity]}"
      end
      params.delete :Items

      item_hash = { ItemName: items.join("#")[0...200] }

      invoice_item_hash = {}
      if params[:InvoiceMark] == InvoiceMark::YES
        invoice_item_hash[:CustomerName] = url_encode(params[:CustomerName] || "")
        invoice_item_hash[:CustomerAddr] = url_encode(params[:CustomerAddr] || "")
        invoice_item_hash[:CustomerEmail] = url_encode(params[:CustomerEmail] || "")

        invoice_item_names = []
        invoice_item_counts = []
        invoice_item_words = []
        invoice_item_prices = []
        invoice_item_tax_types = []
        params[:InvoiceItems].each do |item|
          invoice_item_names << url_encode(item[:name])
          invoice_item_counts << item[:count]
          invoice_item_words << url_encode(item[:word])
          invoice_item_prices << item[:price]
          invoice_item_tax_types << item[:taxType]
        end
        params.delete :InvoiceItems

        invoice_item_hash[:InvoiceItemName] = invoice_item_names.join("|")
        invoice_item_hash[:InvoiceItemCount] = invoice_item_counts.join("|")
        invoice_item_hash[:InvoiceItemWord] = invoice_item_words.join("|")
        invoice_item_hash[:InvoiceItemPrice] = invoice_item_prices.join("|")
        invoice_item_hash[:InvoiceItemTaxType] = invoice_item_tax_types.join("|")
        invoice_item_hash[:InvoiceRemark] = url_encode(params[:InvoiceRemark] || "")
        invoice_item_hash[:DelayDay] = params[:DelayDay] || 0
      end

      service_url = params[:ServiceURL]
      params.delete :ServiceURL

      payment_button = params[:PaymentButton]
      params.delete :PaymentButton

      target = params[:Target] || "_self"
      params.delete :Target

      data = {
        MerchantID: @merchant_id,
        PaymentType: "aio"
      }.merge(params).merge(item_hash).merge(invoice_item_hash)

      unless params.has_key? :CheckMacValue
        data[:CheckMacValue] = gen_check_mac_value(data)
      end

      # 建立表單資料
      html = '<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />';
      html += "<form id='_allpayForm' method='post' target='#{target}' action='#{service_url}'>"
      data.each do |key, value|
        html += "<input type='hidden' name='#{key}' value='#{value}' />"
      end

      if payment_button.nil?
        html += '<script type="text/javascript">document.getElementById("_allpayForm").submit();</script>'
      else
        raise_argument_error(msg: :parameter_should_be, field: :PaymentButton, data: "String") unless payment_button.is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :PaymentButton) if payment_button.empty?
        html += "<input type='submit' id='_paymentButton' value='#{payment_button}' />"
      end

      html += "</form>"

      { "Data" => data.stringify_keys, "Html" => html }
    end

    # 付款結果通知
    def check_out_feedback_valid? params = {}
      raise_argument_error(msg: :parameter_should_be, field: "Parameter", data: "Hash") unless params.is_a? Hash

      return_params = Marshal.load(Marshal.dump(params))
      return_params.delete "CheckMacValue"
      return_params.each do |key, value|
        if key == "PaymentType"
          value["_CVS"] = "" unless value["_CVS"].nil?
          value["_BARCODE"] = "" unless value["_BARCODE"].nil?
          value["_Alipay"] = "" unless value["_Alipay"].nil?
          value["_Tenpay"] = "" unless value["_Tenpay"].nil?
          value["_CreditCard"] = "" unless value["_CreditCard"].nil?
        elsif key == "PeriodType"
          value["Y"] = "Year" unless value["Y"].nil?
          value["M"] = "Month" unless value["M"].nil?
          value["D"] = "Day" unless value["D"].nil?
        end
      end

      raise ErrorMessage.generate(msg: :check_mac_value_verify_fail) unless data_valid?(params)

      return_params
    end

    # 訂單查詢
    def query_trade_info params = {}
      raise_argument_error(msg: :parameter_should_be, field: "Parameter", data: "Hash") unless params.is_a? Hash

      raise_argument_error(msg: :missing_parameter, field: :ServiceURL) if params[:ServiceURL].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ServiceURL, data: "String") unless params[:ServiceURL].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :ServiceURL) if params[:ServiceURL].empty?

      raise_argument_error(msg: :missing_parameter, field: :MerchantTradeNo) if params[:MerchantTradeNo].nil?
      raise_argument_error(msg: :parameter_should_be, field: :MerchantTradeNo, data: "String") unless params[:MerchantTradeNo].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :MerchantTradeNo) if params[:MerchantTradeNo].empty?
      raise_argument_error(msg: :reach_max_length, field: :MerchantTradeNo, length: 20) if params[:MerchantTradeNo].size > 20

      if params.has_key? :PlatformID
        raise_argument_error(msg: :parameter_should_be, field: :PlatformID, data: "String") unless params[:PlatformID].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :PlatformID, length: 10) if params[:PlatformID].size > 10
      end

      if params.has_key? :CheckMacValue
        raise_argument_error(msg: :parameter_should_be, field: :CheckMacValue, data: "String") unless params[:CheckMacValue].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :CheckMacValue) if params[:CheckMacValue].empty?
      end

      service_url = params[:ServiceURL]
      params.delete :ServiceURL

      data = {
        MerchantID: @merchant_id,
        TimeStamp: Time.now.strftime("%s%3N")
      }.merge(params)

      unless params.has_key? :CheckMacValue
        data[:CheckMacValue] = gen_check_mac_value(data)
      end

      # 送出並處理回傳資料
      res = request(method: HttpMethod::HTTP_POST, service_url: service_url, data: data)

      response_data = res.body.hashify

      raise ErrorMessage.generate(msg: :check_mac_value_verify_fail) unless data_valid?(response_data)

      response_data.delete "CheckMacValue"
      response_data
    end

    # 信用卡定期定額訂單查詢
    def query_credit_card_period_info params = {}
      raise_argument_error(msg: :parameter_should_be, field: "Parameter", data: "Hash") unless params.is_a? Hash

      raise_argument_error(msg: :missing_parameter, field: :ServiceURL) if params[:ServiceURL].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ServiceURL, data: "String") unless params[:ServiceURL].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :ServiceURL) if params[:ServiceURL].empty?

      raise_argument_error(msg: :missing_parameter, field: :MerchantTradeNo) if params[:MerchantTradeNo].nil?
      raise_argument_error(msg: :parameter_should_be, field: :MerchantTradeNo, data: "String") unless params[:MerchantTradeNo].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :MerchantTradeNo) if params[:MerchantTradeNo].empty?
      raise_argument_error(msg: :reach_max_length, field: :MerchantTradeNo, length: 20) if params[:MerchantTradeNo].size > 20

      if params.has_key? :CheckMacValue
        raise_argument_error(msg: :parameter_should_be, field: :CheckMacValue, data: "String") unless params[:CheckMacValue].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :CheckMacValue) if params[:CheckMacValue].empty?
      end

      service_url = params[:ServiceURL]
      params.delete :ServiceURL

      data = {
        MerchantID: @merchant_id,
        TimeStamp: Time.now.strftime("%s%3N")
      }.merge(params)

      unless params.has_key? :CheckMacValue
        data[:CheckMacValue] = gen_check_mac_value(data)
      end

      # 送出並處理回傳資料
      res = request(method: HttpMethod::HTTP_POST, service_url: service_url, data: data)

      JSON.parse(res.body)
    end

    # 信用卡關帳/退刷/取消/放棄
    def do_action params = {}
      raise_argument_error(msg: :parameter_should_be, field: "Parameter", data: "Hash") unless params.is_a? Hash

      raise_argument_error(msg: :missing_parameter, field: :ServiceURL) if params[:ServiceURL].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ServiceURL, data: "String") unless params[:ServiceURL].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :ServiceURL) if params[:ServiceURL].empty?

      raise_argument_error(msg: :missing_parameter, field: :MerchantTradeNo) if params[:MerchantTradeNo].nil?
      raise_argument_error(msg: :parameter_should_be, field: :MerchantTradeNo, data: "String") unless params[:MerchantTradeNo].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :MerchantTradeNo) if params[:MerchantTradeNo].empty?
      raise_argument_error(msg: :reach_max_length, field: :MerchantTradeNo, length: 20) if params[:MerchantTradeNo].size > 20

      raise_argument_error(msg: :missing_parameter, field: :TradeNo) if params[:TradeNo].nil?
      raise_argument_error(msg: :parameter_should_be, field: :TradeNo, data: "String") unless params[:TradeNo].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :TradeNo) if params[:TradeNo].empty?
      raise_argument_error(msg: :reach_max_length, field: :TradeNo, length: 20) if params[:TradeNo].size > 20

      raise_argument_error(msg: :missing_parameter, field: :Action) if params[:Action].nil?
      raise_argument_error(msg: :parameter_should_be, field: :Action, data: "String") unless params[:Action].is_a? String
      raise_argument_error(msg: :parameter_should_be, field: :Action, data: ActionType.readable_keys) unless ActionType.values.include? params[:Action]

      raise_argument_error(msg: :missing_parameter, field: :TotalAmount) if params[:TotalAmount].nil?
      raise_argument_error(msg: :parameter_should_be, field: :TotalAmount, data: "Integer") unless params[:TotalAmount].is_a? Integer
      raise_argument_error(msg: :parameter_should_be, field: :TotalAmount, data: "greater than 0") if params[:TotalAmount] <= 0

      if params.has_key? :PlatformID
        raise_argument_error(msg: :parameter_should_be, field: :PlatformID, data: "String") unless params[:PlatformID].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :PlatformID, length: 10) if params[:PlatformID].size > 10
      end

      if params.has_key? :CheckMacValue
        raise_argument_error(msg: :parameter_should_be, field: :CheckMacValue, data: "String") unless params[:CheckMacValue].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :CheckMacValue) if params[:CheckMacValue].empty?
      end

      service_url = params[:ServiceURL]
      params.delete :ServiceURL

      data = {
        MerchantID: @merchant_id
      }.merge(params)

      unless params.has_key? :CheckMacValue
        data[:CheckMacValue] = gen_check_mac_value(data)
      end

      # 送出並處理回傳資料
      res = request(method: HttpMethod::HTTP_POST, service_url: service_url, data: data)

      res.body.hashify
    end

    # 廠商通知退款
    def aio_chargeback params = {}
      raise_argument_error(msg: :parameter_should_be, field: "Parameter", data: "Hash") unless params.is_a? Hash

      raise_argument_error(msg: :missing_parameter, field: :ServiceURL) if params[:ServiceURL].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ServiceURL, data: "String") unless params[:ServiceURL].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :ServiceURL) if params[:ServiceURL].empty?

      raise_argument_error(msg: :missing_parameter, field: :MerchantTradeNo) if params[:MerchantTradeNo].nil?
      raise_argument_error(msg: :parameter_should_be, field: :MerchantTradeNo, data: "String") unless params[:MerchantTradeNo].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :MerchantTradeNo) if params[:MerchantTradeNo].empty?
      raise_argument_error(msg: :reach_max_length, field: :MerchantTradeNo, length: 20) if params[:MerchantTradeNo].size > 20

      raise_argument_error(msg: :missing_parameter, field: :TradeNo) if params[:TradeNo].nil?
      raise_argument_error(msg: :parameter_should_be, field: :TradeNo, data: "String") unless params[:TradeNo].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :TradeNo) if params[:TradeNo].empty?
      raise_argument_error(msg: :reach_max_length, field: :TradeNo, length: 20) if params[:TradeNo].size > 20

      raise_argument_error(msg: :missing_parameter, field: :ChargeBackTotalAmount) if params[:ChargeBackTotalAmount].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ChargeBackTotalAmount, data: "Integer") unless params[:ChargeBackTotalAmount].is_a? Integer
      raise_argument_error(msg: :parameter_should_be, field: :ChargeBackTotalAmount, data: "greater than 0") if params[:ChargeBackTotalAmount] <= 0

      if params.has_key? :Remark
        raise_argument_error(msg: :parameter_should_be, field: :Remark, data: "String") unless params[:Remark].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :Remark, length: 100) if params[:Remark].size > 100
      end

      if params.has_key? :PlatformID
        raise_argument_error(msg: :parameter_should_be, field: :PlatformID, data: "String") unless params[:PlatformID].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :PlatformID, length: 10) if params[:PlatformID].size > 10
      end

      if params.has_key? :CheckMacValue
        raise_argument_error(msg: :parameter_should_be, field: :CheckMacValue, data: "String") unless params[:CheckMacValue].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :CheckMacValue) if params[:CheckMacValue].empty?
      end

      service_url = params[:ServiceURL]
      params.delete :ServiceURL

      data = {
        MerchantID: @merchant_id
      }.merge(params)

      unless params.has_key? :CheckMacValue
        data[:CheckMacValue] = gen_check_mac_value(data)
      end

      # 送出並處理回傳資料
      res = request(method: HttpMethod::HTTP_POST, service_url: service_url, data: data)

      result = res.body.force_encoding("UTF-8")

      if result == "1|OK"
        return_code, return_message = result.split("|")
        { "RtnCode" => return_code, "RtnMsg" => return_message }
      else
        raise result.gsub(/-/, ": ")
      end
    end

    # 廠商申請撥款/退款
    def capture params = {}
      raise_argument_error(msg: :parameter_should_be, field: "Parameter", data: "Hash") unless params.is_a? Hash

      raise_argument_error(msg: :missing_parameter, field: :ServiceURL) if params[:ServiceURL].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ServiceURL, data: "String") unless params[:ServiceURL].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :ServiceURL) if params[:ServiceURL].empty?

      raise_argument_error(msg: :missing_parameter, field: :MerchantTradeNo) if params[:MerchantTradeNo].nil?
      raise_argument_error(msg: :parameter_should_be, field: :MerchantTradeNo, data: "String") unless params[:MerchantTradeNo].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :MerchantTradeNo) if params[:MerchantTradeNo].empty?
      raise_argument_error(msg: :reach_max_length, field: :MerchantTradeNo, length: 20) if params[:MerchantTradeNo].size > 20

      raise_argument_error(msg: :missing_parameter, field: :CaptureAMT) if params[:CaptureAMT].nil?
      raise_argument_error(msg: :parameter_should_be, field: :CaptureAMT, data: "Integer") unless params[:CaptureAMT].is_a? Integer
      raise_argument_error(msg: :parameter_should_be, field: :CaptureAMT, data: "greater than or equal to 0") if params[:CaptureAMT] < 0

      raise_argument_error(msg: :missing_parameter, field: :UserRefundAMT) if params[:UserRefundAMT].nil?
      raise_argument_error(msg: :parameter_should_be, field: :UserRefundAMT, data: "Integer") unless params[:UserRefundAMT].is_a? Integer
      raise_argument_error(msg: :parameter_should_be, field: :UserRefundAMT, data: "greater than or equal to 0") if params[:UserRefundAMT] < 0

      raise_argument_error(msg: :parameter_should_be, field: "CaptureAMT + UserRefundAMT", data: "greater than 0") if params[:CaptureAMT] + params[:UserRefundAMT] == 0

      if params[:UserRefundAMT] > 0
        raise_argument_error(msg: :missing_parameter, field: :UserName) if params[:UserName].nil?
        raise_argument_error(msg: :parameter_should_be, field: :UserName, data: "String") unless params[:UserName].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :UserName) if params[:UserName].empty?
        raise_argument_error(msg: :reach_max_length, field: :UserName, length: 20) if params[:UserName].size > 20

        raise_argument_error(msg: :missing_parameter, field: :UserCellPhone) if params[:UserCellPhone].nil?
        raise_argument_error(msg: :parameter_should_be, field: :UserCellPhone, data: "String") unless params[:UserCellPhone].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :UserCellPhone) if params[:UserCellPhone].empty?
        raise_argument_error(msg: :reach_max_length, field: :UserCellPhone, length: 20) if params[:UserCellPhone].size > 20
      end

      if params.has_key? :PlatformID and params[:PlatformID] != ""
        raise_argument_error(msg: :parameter_should_be, field: :PlatformID, data: "String") unless params[:PlatformID].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :PlatformID, length: 10) if params[:PlatformID].size > 10
      else
        raise_argument_error(msg: :remove_parameter, field: :UpdatePlatformChargeFee) if params.has_key? :UpdatePlatformChargeFee
        raise_argument_error(msg: :remove_parameter, field: :PlatformChargeFee) if params.has_key? :PlatformChargeFee
      end

      if params.has_key? :UpdatePlatformChargeFee
        raise_argument_error(msg: :parameter_should_be, field: :UpdatePlatformChargeFee, data: "String") unless params[:UpdatePlatformChargeFee].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :UpdatePlatformChargeFee, data: "N or Y") unless %w(N Y).include? params[:UpdatePlatformChargeFee]
      end

      if params[:UpdatePlatformChargeFee] == "Y"
        raise_argument_error(msg: :missing_parameter, field: :PlatformChargeFee) if params[:PlatformChargeFee].nil?
        raise_argument_error(msg: :parameter_should_be, field: :PlatformChargeFee, data: "Integer") unless params[:PlatformChargeFee].is_a? Integer
        raise_argument_error(msg: :parameter_should_be, field: :PlatformChargeFee, data: "greater than or equal to 0") if params[:PlatformChargeFee] < 0
      else
        raise_argument_error(msg: :remove_parameter, field: :PlatformChargeFee) if params.has_key? :PlatformChargeFee
      end

      if params.has_key? :Remark
        raise_argument_error(msg: :parameter_should_be, field: :Remark, data: "String") unless params[:Remark].is_a? String
        raise_argument_error(msg: :reach_max_length, field: :Remark, length: 30) if params[:Remark].size > 30
      end

      if params.has_key? :CheckMacValue
        raise_argument_error(msg: :parameter_should_be, field: :CheckMacValue, data: "String") unless params[:CheckMacValue].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :CheckMacValue) if params[:CheckMacValue].empty?
      end

      service_url = params[:ServiceURL]
      params.delete :ServiceURL

      data = {
        MerchantID: @merchant_id
      }.merge(params)

      unless params.has_key? :CheckMacValue
        data[:CheckMacValue] = gen_check_mac_value(data)
      end

      # 送出並處理回傳資料
      res = request(method: HttpMethod::HTTP_POST, service_url: service_url, data: data)

      res.body.hashify
    end

    # 下載廠商對帳媒體檔
    def download_aio_payment_media params = {}
      raise_argument_error(msg: :parameter_should_be, field: "Parameter", data: "Hash") unless params.is_a? Hash

      raise_argument_error(msg: :missing_parameter, field: :ServiceURL) if params[:ServiceURL].nil?
      raise_argument_error(msg: :parameter_should_be, field: :ServiceURL, data: "String") unless params[:ServiceURL].is_a? String
      raise_argument_error(msg: :cannot_be_empty, field: :ServiceURL) if params[:ServiceURL].empty?

      raise_argument_error(msg: :missing_parameter, field: :DateType) if params[:DateType].nil?
      raise_argument_error(msg: :parameter_should_be, field: :DateType, data: "String") unless params[:DateType].is_a? String
      raise_argument_error(msg: :parameter_should_be, field: :DateType, data: TradeDateType.readable_keys) unless TradeDateType.values.include? params[:DateType]

      raise_argument_error(msg: :missing_parameter, field: :BeginDate) if params[:BeginDate].nil?
      raise_argument_error(msg: :parameter_should_be, field: :BeginDate, data: "String") unless params[:BeginDate].is_a? String
      raise_argument_error(msg: :wrong_data_format, field: :BeginDate) unless /\A\d{4}-\d{2}-\d{2}\z/.match(params[:BeginDate])

      raise_argument_error(msg: :missing_parameter, field: :EndDate) if params[:EndDate].nil?
      raise_argument_error(msg: :parameter_should_be, field: :EndDate, data: "String") unless params[:EndDate].is_a? String
      raise_argument_error(msg: :wrong_data_format, field: :EndDate) unless /\A\d{4}-\d{2}-\d{2}\z/.match(params[:EndDate])

      raise_argument_error(msg: :missing_parameter, field: :MediaFormated) if params[:MediaFormated].nil?
      raise_argument_error(msg: :parameter_should_be, field: :MediaFormated, data: "String") unless params[:MediaFormated].is_a? String
      raise_argument_error(msg: :parameter_should_be, field: :MediaFormated, data: MediaFormat.readable_keys) unless MediaFormat.values.include? params[:MediaFormated]

      raise_argument_error(msg: :missing_parameter, field: :FilePath) if params[:FilePath].nil?
      raise_argument_error(msg: :parameter_should_be, field: :FilePath, data: "String") unless params[:FilePath].is_a? String

      if params.has_key? :PaymentType
        raise_argument_error(msg: :parameter_should_be, field: :PaymentType, data: "String") unless params[:PaymentType].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :PaymentType, data: PaymentType.readable_keys) unless PaymentType.values.include? params[:PaymentType]

        # 若為全部時，忽略此參數
        params.delete :PaymentType if params[:PaymentType] == PaymentType::ALL
      end

      if params.has_key? :PlatformStatus
        raise_argument_error(msg: :parameter_should_be, field: :PlatformStatus, data: "String") unless params[:PlatformStatus].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :PlatformStatus, data: PlatformStatus.readable_keys) unless PlatformStatus.values.include? params[:PlatformStatus]

        # 若為全部時，忽略此參數
        params.delete :PlatformStatus if params[:PlatformStatus] == PlatformStatus::ALL
      end

      if params.has_key? :PaymentStatus
        raise_argument_error(msg: :parameter_should_be, field: :PaymentStatus, data: "String") unless params[:PaymentStatus].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :PaymentStatus, data: PaymentStatus.readable_keys) unless PaymentStatus.values.include? params[:PaymentStatus]

        # 若為全部時，忽略此參數
        params.delete :PaymentStatus if params[:PaymentStatus] == PaymentStatus::ALL
      end

      if params.has_key? :AllocateStatus
        raise_argument_error(msg: :parameter_should_be, field: :AllocateStatus, data: "String") unless params[:AllocateStatus].is_a? String
        raise_argument_error(msg: :parameter_should_be, field: :AllocateStatus, data: AllocateStatus.readable_keys) unless AllocateStatus.values.include? params[:AllocateStatus]

        # 若為全部時，忽略此參數
        params.delete :AllocateStatus if params[:AllocateStatus] == AllocateStatus::ALL
      end

      if params.has_key? :CheckMacValue
        raise_argument_error(msg: :parameter_should_be, field: :CheckMacValue, data: "String") unless params[:CheckMacValue].is_a? String
        raise_argument_error(msg: :cannot_be_empty, field: :CheckMacValue) if params[:CheckMacValue].empty?
      end

      service_url = params[:ServiceURL]
      params.delete :ServiceURL

      file_path = params[:FilePath]
      params.delete :FilePath

      data = {
        MerchantID: @merchant_id
      }.merge(params)

      unless params.has_key? :CheckMacValue
        data[:CheckMacValue] = gen_check_mac_value(data)
      end

      # 送出並處理回傳資料
      res = request(method: HttpMethod::HTTP_POST, service_url: service_url, data: data)

      # 作業系統不是 Windows 時，將 Big5 編碼內容轉換為 UTF-8
      if os_is_windows?
        csv_data = res.body
      else
        csv_data = res.body.encode("UTF-8", "Big5", invalid: :replace, undef: :replace, replace: "?")
      end

      File.write(file_path, csv_data)
    end

    # 產生檢查碼
    def gen_check_mac_value data = {}
      raise_argument_error(msg: :parameter_should_be, field: "Parameter", data: "Hash") unless data.is_a? Hash

      hash_key = data[:HashKey] || data["HashKey"] || @hash_key
      hash_iv = data[:HashIV] || data["HashIV"] || @hash_iv

      # 移除不必要欄位
      data.delete(:CheckMacValue) if data.has_key? :CheckMacValue
      data.delete("CheckMacValue") if data.has_key? "CheckMacValue"
      data.delete(:HashKey) if data.has_key? :HashKey
      data.delete("HashKey") if data.has_key? "HashKey"
      data.delete(:HashIV) if data.has_key? :HashIV
      data.delete("HashIV") if data.has_key? "HashIV"

      # 將資料自然排序並串接
      raw = data.sort_by{ |key,| key.downcase }.map{ |key, value| "#{key}=#{value}" }.join("&")
      raw = url_encode("HashKey=#{hash_key}&#{raw}&HashIV=#{hash_iv}")

      case data[:EncryptType]
      when nil, EncryptType::MD5
        checksum = Digest::MD5.hexdigest raw
      when EncryptType::SHA256
        checksum = Digest::SHA256.hexdigest raw
      else
        raise_argument_error(msg: :parameter_should_be, field: :EncryptType, data: EncryptType.readable_keys) unless Allpay::EncryptType.values.include? data[:EncryptType]
      end

      checksum.upcase
    end

    # 檢查資料正確性
    def data_valid? data = {}
      original_check_mac_value = data["CheckMacValue"] || data[:CheckMacValue]
      generated_check_mac_value = gen_check_mac_value(data)

      original_check_mac_value == generated_check_mac_value
    end

    private

      def raise_argument_error params
        raise ArgumentError, ErrorMessage.generate(params)
      end

      # 將資料依照 URLENCODE 轉換表進行編碼
      def url_encode data
        return data if data.nil? or data.empty?

        uri_parser = URI::Parser.new
        encoded_data = uri_parser.escape(data, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).downcase

        # 取代字元以符合「.NET 編碼(ALLPAY)」
        encoded_data.gsub!("~", "%7e")
        encoded_data.gsub!("%20", "+")
        encoded_data.gsub!("'", "%27")

        encoded_data
      end

      # 發送 HTTP 請求
      def request method:, service_url:, data:
        api_url = URI.parse(service_url)

        case method
        when HttpMethod::HTTP_GET
          api_url.query = URI.encode_www_form data
          http_response = Net::HTTP.get_response api_url
        when HttpMethod::HTTP_POST
          http_response = Net::HTTP.post_form api_url, data
        else
          raise ArgumentError, "Unsupported HTTP method"
        end

        case http_response
        when Net::HTTPOK
          http_response
        when Net::HTTPClientError, Net::HTTPInternalServerError
          raise Net::HTTPError.new(http_response.message, http_response)
        else
          raise Net::HTTPError.new("Unexpected HTTP response.", http_response)
        end
      end

      # 檢查作業系統是否為 Windows
      def os_is_windows?
        host_os = RbConfig::CONFIG["host_os"]
        matched_result = host_os =~ /mswin|msys|mingw|cygwin|bccwin|wince|emc/

        matched_result.nil? ? false : true
      end
  end
end
