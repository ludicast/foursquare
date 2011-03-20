package com.ludicast.foursquare.business
{
	public class ProxiedFoursquareDelegate extends AbstractFoursquareDelegate {
		private var proxyUrl:String = "";
		public function ProxiedFoursquareDelegate(proxyUrl:String) {
			this.proxyUrl = proxyUrl;
		}
		protected override function constructUrl(path:String):String {
			return proxyUrl + path;
		}
	
	}
}