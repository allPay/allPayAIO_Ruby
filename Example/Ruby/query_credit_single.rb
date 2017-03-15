require 'allpay_payment'

class YOURCONTROLLER < ApplicationController

  def QueryTrade
    ## 參數值為[PLEASE MODIFY]者，請在每次測試時給予獨特值
    ## 若要測試非必帶參數請將base_param內註解的參數依需求取消註解 ##
    ## 在測試環境因為沒有實際授權，此API僅會回傳{"RtnMsg":"","RtnValue":null}，但代表API連線正常
    base_param = {
      'CreditRefundId' => '10123456',
      'CreditAmount' => '100',  
      'CreditCheckCode' => '59997889' 
    }


    create = AllpayPayment::PaymentClient.new
    res = query.query_credit_single(base_param)
    render :text => res
  end
