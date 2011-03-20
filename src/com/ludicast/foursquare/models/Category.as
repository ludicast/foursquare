package com.ludicast.foursquare.models
{
	import mx.collections.ICollectionView;

	public class Category {
		public var id:String;
		public var name:String;
		public var icon:String;
		public var categories:Vector.<Category> = new Vector.<Category>();
		
		public function toString():String {
			return name;
		}
	
		public function get subCategories():Array {
			var catArray:Array = [];
			for each (var cat:Category in categories) {
				catArray.push(cat);
			}
			return catArray;
		}
	}
}