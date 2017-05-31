require 'allpay_invoice'

class YOURCONTROLLER < ApplicationController
	# 查詢發票明細
	def InvQueryIssue
		## 參數值為[PLEASE MODIFY]者，請每次測試時給予獨特值
		query_issue_dict = {
			"RelateNumber"=>"24h2398net43n89jf9jq78379h835h" # 輸入合作特店自訂的編號，長度為30字元
		}	
		
		query_issue = AllpayInvoice::QueryClient.new # 將模組中的class實例化
		res = query_issue.query_invoice_issue(query_issue_dict) # 對class中的對應的method傳入位置參數
		
		render :text => res # 將回傳結果列印出來
	end