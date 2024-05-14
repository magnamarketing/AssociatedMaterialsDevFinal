/**
	* @author CRMCulture
	* @author jmarkey
	* @version 1.00
	* @description Controls login for the ami claims app
*/
public with sharing class LoginController {
	
	public String username {get; set;}
    public String password {get; set;}
    public String origin {get; set;}
    
    public PageReference login() {
    	if(!String.isBlank(origin)) {
        	origin = '?'+origin;
        }
        if(Site.login(username, password, '/amiclaims'+origin)==null) {
        	return new PageReference('/CommunitiesLogin');
        }else {
			return Site.login(username, password, '/amiclaims'+origin);
        }
    }
    
}