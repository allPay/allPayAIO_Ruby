require 'allpay_invoice'

class YOURCONTROLLER < ApplicationController
	# 手機條碼驗證
	def InvQueryCheckMobileBarCode
		## 參數值為[PLEASE MODIFY]者，請每次測試時給予獨特值
		query_check_barcode_dict = {
			"BarCode"=>"/RXNOFER" # 手機條碼，長度為7字元
		}	
		query_check_barcode = AllpayInvoice::QueryClient.new # 將模組中的class實例化
		res = query_check_barcode.query_check_mob_barcode(query_check_barcode_dict) # 對class中的對應的method傳入位置參數
		
		render :text => res # 將回傳結果列印出來
	end