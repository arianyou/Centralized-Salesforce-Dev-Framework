/**
* @author Scott Covert
* @date 6/17/2016
* @description This class provides unit tests for the QueueableHandler test class
*/
@isTest (seealldata=false)
public with sharing class QueueableHandlerTest { 

	/** Constant representing endpoint of external API for testing */
	private static final String TEST_ENDPOINT = 'https://httpbin.org/get';

	/** 
	* @author Scott Covert
	* @date 6/17/2016
	* @description Tests the QueueableHandler methods
	*/
	@isTest (seealldata=false)
	public static void testQueueableHandler() {	        
        
		if (!TestVerificationService.ShouldExecute('QueueableHandlerTest.testQueueableHandler')) return;

		// Test Async Request Queue is functional
		QueueableHandler.startCalloutJob(QueueableHandler.CALLOUT_TOKEN, new CalloutRequest__c(Endpoint__c = TEST_ENDPOINT, Method__c = CalloutHandler.GET_METHOD, Timeout__c = CalloutHandler.DEFAULT_CALLOUT_TIME));
		list<AsyncRequest__c> asyncRequests = [SELECT Id FROM AsyncRequest__c WHERE Aborted__c = false];
		System.assertNotEquals(0,asyncRequests.size(),'Error in QueueableHandler.startJob: Async Request record(s) not being properly inserted to the database/queue');
		QueueableHandler.startDelayedJob(QueueableHandler.ASYNC_TOKEN, System.now().addMinutes(5));
		asyncRequests = [SELECT Id FROM AsyncRequest__c WHERE Aborted__c = false AND ScheduledTime__c > :System.now()];
		System.assertNotEquals(0,asyncRequests.size(),'Error in QueueableHandler.startDelayedJob: Delayed Async Request record(s) not being properly inserted to the database/queue');
		(new QueueableHandler()).flushAsyncQueue();
		asyncRequests = [SELECT Id FROM AsyncRequest__c WHERE Aborted__c = false];
		System.assertEquals(0,asyncRequests.size(),'Error in QueueableHandler.flushAsyncQueue(): Async Request record(s) not being properly flushed from the database/queue');
	}

}