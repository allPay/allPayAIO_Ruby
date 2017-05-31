require 'allpay_invoice'

class YOURCONTROLLER < ApplicationController
	# 觸發開立發票
	def InvTrigger
		## 參數值為[PLEASE MODIFY]者，請每次測試時給予獨特值
		inv_trigger_dict = {
			"Tsr"=>"PLEASE MODIFY", # 交易單號，為invoice_delay時所填入的，請帶30碼uid, ex: f0a0d7e9fae1bb72bc93jg3495234
			"PayType"=>"3" # 交易類別，請固定帶'3'
		}
		
		inv_trigger = AllpayInvoice::InvoiceClient.new # 將模組中的class實例化
		res = inv_trigger.invoice_trigger(inv_trigger_dict) # 對class中的對應的method傳入位置參數
		
		render :text => res # 將回傳結果列印出來
	end