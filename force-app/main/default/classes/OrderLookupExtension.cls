/*
Company    : Fujitsu America
Date       : Feb 2010
Author     : Anand Sharma
Description: Extension for visual force page Order Lookup 
History    :              
*/
public with sharing class OrderLookupExtension {
	//properties
	
	//holds current Case record
	public Case currentCase{get; set;}
	
	//true if Case has value in customer lookup, false otherwise
	public boolean isCustomerPresent{get; set;}
	
	//holds list of orders related to current case record's customer
	public List<Order__c> lstOrders {get; set;}	
	
	//holds the selected Order id
	public Id selectedOrderId{get; set;}
	
	//true is there are orders, false otherwise
	public boolean isOrdersListEmpty{get; set;}	
	
	//constructor
	public OrderLookupExtension(ApexPages.StandardController controller){
		this.currentCase = (Case)controller.getRecord();
		this.isCustomerPresent = false;
		this.isOrdersListEmpty = true;
		this.lstOrders = new List<Order__c>();
		this.selectedOrderId = null;
		this.fetchCaseRecord();
		this.fetchOrders();
	}	
	
	//methods
	
	//fetches current Case record 
	private void fetchCaseRecord(){
		if(this.currentCase.Id != null){
			this.currentCase = [select Id, AccountId, Account.Name
			                    from Case
			                    where Id = :this.currentCase.Id ];
			if(this.currentCase.AccountId != null){
				this.isCustomerPresent = true;
			}                    
		}
	}
	
	//fetches Orders based on current Case records's Customer 
	private void fetchOrders(){
		if(this.isCustomerPresent){
			Date dateLimit = Date.today().addDays(-60);
			this.lstOrders = [select Id, Name, Purchase_Order__c, Customer_Purchase_Order__c, Order_Date__c
			                  from Order__c
			                  where Customer__c = :this.currentCase.AccountId 
			                  and Order_Date__c >= :dateLimit
			                  Limit 1000 ];		  
			if(this.lstOrders.size() > 0){
				this.isOrdersListEmpty = false;
			}                    	
		}
	}
	
	//cancel operation
	public PageReference cancel(){
		return this.redirectToCase();
	}
	
	//returns page reference to the current case page
	private PageReference redirectToCase(){
		PageReference casePage = new PageReference('/' + this.currentCase.Id);
		casePage.setRedirect(true);
		return casePage;
	}
	
	//adds the selected order in current case record's order lookup,updates the current case record
	//and redirects to case detail page
	public PageReference updateCase(){
		if(this.selectedOrderId != null){
			this.currentCase.Order__c = this.selectedOrderId;
			update this.currentCase;
		}
		return this.redirectToCase();
	}

}