package com.ludicast.foursquare.models
{
	public class Category {
		public var id:String;
		public var name:String;
		public var icon:String;
		public var categories:Vector.<Category> = new Vector.<Category>();
		
		public function toString():String {
			return "{ name: " + name + " subCategories: [" + categories + "] }"
		}
	}
}