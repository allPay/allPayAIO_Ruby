require 'allpay_invoice'

class YOURCONTROLLER < ApplicationController
	# 愛心碼碼驗證
	def InvQueryCheckLoveCode
		## 參數值為[PLEASE MODIFY]者，請每次測試時給予獨特值
		query_check_lovecode_dict = {
			"LoveCode"=>"329580" # 愛心碼，長度為7字元
		}	
		query_check_lovecode = AllpayInvoice::QueryClient.new # 將模組中的class實例化
		res = query_check_lovecode.query_check_love_code(query_check_lovecode_dict) # 對class中的對應的method傳入位置參數
		
		render :text => res # 將回傳結果列印出來
	end