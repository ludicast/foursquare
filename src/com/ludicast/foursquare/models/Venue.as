package com.ludicast.foursquare.models
{
	public class Venue {
		public var id:String;
		public var name:String;
		public var currentCheckins:Vector.<Checkin>;
		public var categories:Vector.<Category>;
		public var verified:Boolean;	
		public var contact:Contact;
		public var location:Location;
		public var mayor:Mayor;
	}
}