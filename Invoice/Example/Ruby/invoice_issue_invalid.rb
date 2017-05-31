require 'allpay_invoice'

class YOURCONTROLLER < ApplicationController
	# 作廢發票
	def InvIssueInvalid
		## 參數值為[PLEASE MODIFY]者，請每次測試時給予獨特值
		inv_issue_invalid_dict = {
			"InvoiceNumber"=>"RH00001423", # 發票號碼，長度為10字元
			"Reason"=>"test" # 作廢原因，長度為20字元
		}
		
		inv_issue_invalid = AllpayInvoice::InvoiceClient.new # 將模組中的class實例化
		res = inv_issue_invalid.invoice_issue_invalid(inv_issue_invalid_dict) # 對class中的對應的method傳入位置參數
		
		render :text => res # 將回傳結果列印出來
	end