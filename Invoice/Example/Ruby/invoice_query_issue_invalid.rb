require 'allpay_invoice'

class YOURCONTROLLER < ApplicationController
	# 查詢作廢發票明細
	def InvQueryIssueInvalid
		## 參數值為[PLEASE MODIFY]者，請每次測試時給予獨特值
		query_issue_invalid_dict = {
			"RelateNumber"=>"35hr89qgtq2wh7843rhf9wh423qr39" # 輸入合作特店自訂的編號，長度為30字元
		}	
		
		query_issue_invalid = AllpayInvoice::QueryClient.new # 將模組中的class實例化
		res = query_issue_invalid.query_invoice_issue_invalid(query_issue_invalid_dict) # 對class中的對應的method傳入位置參數
		
		render :text => res # 將回傳結果列印出來
	end