package com.ludicast.foursquare.business
{
	import com.adobe.serialization.json.JSON;
	import com.ludicast.foursquare.models.*;
	
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.profiler.showRedrawRegions;
	
	import mx.controls.Alert;
	import mx.rpc.IResponder;
	import mx.rpc.events.ResultEvent;
	
	import org.benrimbey.factory.VOInstantiator;
	
	import spark.primitives.Path;
	
	public class AuthenticatedFoursquareDelegate extends AbstractFoursquareDelegate {
		
		private static const API_URL:String = "https://api.foursquare.com/v2/"
		
		public function AuthenticatedFoursquareDelegate(accessKey:String) {
			this.accessKey = accessKey;
		}
		
		protected function authorize(url:String):String {
			var joinToken:String = "?";
			if (url.indexOf("?") != -1) {
				joinToken = "&";
			}
			return url + joinToken + "oauth_token=" + accessKey;
 		}
		
		protected override function constructUrl(path:String):String {
			return authorize(API_URL + path);
		}
	}
}