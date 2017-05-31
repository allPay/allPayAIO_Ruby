require 'allpay_invoice'

class YOURCONTROLLER < ApplicationController
	# 開立折讓
	def InvAllowance
		## 參數值為[PLEASE MODIFY]者，請每次測試時給予獨特值
		inv_allowance_dict = {
			"InvoiceNo"=>"RH00001422", # 發票號碼，長度為10字元
			"AllowanceNotify"=>"E", # 通知類別
			"CustomerName"=>"", # 客戶名稱
			"NotifyPhone"=>"0922652130", # 通知手機號碼
			"NotifyMail"=>"ying.wu@allpay.com.tw", # 通知電子信箱
			"AllowanceAmount"=>"300", # 折讓單總金額
			"ItemName"=>"洗衣精", # 商品名稱，如果超過一樣商品時請以｜分隔
			"ItemCount"=>"3", # 商品數量，如果超過一樣商品時請以｜分隔
			"ItemWord"=>"瓶", # 商品單位，如果超過一樣商品時請以｜分隔
			"ItemPrice"=>"100", # 商品價格，如果超過一樣商品時請以｜分隔
			"ItemTaxType"=>"3", # 商品課稅別，如果超過一樣商品時請以｜分隔
			"ItemAmount"=>"300" # 商品合計，如果超過一樣商品時請以｜分隔
		} 
		
		inv_allowance = AllpayInvoice::InvoiceClient.new # 將模組中的class實例化
		res = inv_allowance.invoice_allowance(inv_allowance_dict) # 對class中的對應的method傳入位置參數
		
		render :text => res # 將回傳結果列印出來
	end