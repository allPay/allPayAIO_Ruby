require 'allpay_invoice'

class YOURCONTROLLER < ApplicationController
	# 發送發票通知
	def InvNotify
		## 參數值為[PLEASE MODIFY]者，請每次測試時給予獨特值
		inv_notify_dict = {
			"InvoiceNo"=>"RH00001345", # 發票號碼，長度為10字元，必填欄位
			"AllowanceNo"=>"2017021714056192", # 折讓號碼，長度為16字元，當InvoiceTag為'A' 或 'AI'時為必填
			"Phone"=>"0922652130", # 發送簡訊號碼，長度為20字元，當Notify為'S' 或 'A'時為必填
			"NotifyMail"=>"", # 發送電子郵件，長度為80字元，當Notify為'E' 或 'A'時為必填
			"Notify"=>"S", # 發送方式，僅可帶入'S'、'E'、'A'
			"InvoiceTag"=>"AI", # 發送內容類型，僅可帶入'I'、'II'、'A'、'AI'、'AW'
			"Notified"=>"A" # 發送對象，僅可帶入'C'、'M'、'A'
		}
		
		inv_notify = AllpayInvoice::NotifyClient.new # 將模組中的class實例化
		res = inv_notify.invoice_notify(inv_notify_dict) # 對class中的對應的method傳入位置參數
		
		render :text => res # 將回傳結果列印出來
	end