require 'allpay_invoice'

class YOURCONTROLLER < ApplicationController
	# 查詢折讓明細
	def InvQueryAllowance
		## 參數值為[PLEASE MODIFY]者，請每次測試時給予獨特值
		query_allowance_dict = {
			"InvoiceNo"=>"RH00001424", # 發票號碼，長度為10字元
			"AllowanceNo"=>"2017022014544449" # 折讓號碼，長度為16字元
		}	
		
		query_allowance = AllpayInvoice::QueryClient.new # 將模組中的class實例化
		res = query_allowance.query_invoice_allowance(query_allowance_dict) # 對class中的對應的method傳入位置參數
		
		render :text => res # 將回傳結果列印出來
	end