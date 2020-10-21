public with sharing class CloneAccountCtrl {
	public Flow.Interview.Clone_IA_Account cloneAccountFlow {get;set;}

	public CloneAccountCtrl(ApexPages.StandardController sc){}

	public PageReference getFinishLocation(){
		return (cloneAccountFlow != null && cloneAccountFlow.originalAccount != null && cloneAccountFlow.originalAccount.Id != null) ?
			new PageReference('/' + cloneAccountFlow.originalAccount.Id) :
			null;
	}
}