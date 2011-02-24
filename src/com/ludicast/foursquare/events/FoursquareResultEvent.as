package com.ludicast.foursquare.events
{
	import flash.events.DataEvent;
	
	import mx.messaging.messages.IMessage;
	import mx.rpc.AsyncToken;
	import mx.rpc.events.ResultEvent;
	
	public class FoursquareResultEvent extends ResultEvent
	{
		public static const FOURSQUARE_RESULT:String = "foursquareResult";
		
		public function FoursquareResultEvent(result:Object)
		{
			super(FOURSQUARE_RESULT,false,true,result);
		}
	}
}