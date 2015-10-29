var map;
function initMap() {
	map = new google.maps.Map(document.getElementById('map'), {
	center: {lat: 55.75, lng: 37.590},
	zoom: 9,
	disableDefaultUI: true

	});
	var styles = [
	{
		stylers: [
		{ hue: "#00ffe6" },
		{ saturation: -80 }
		]
	},
	{
		featureType: "road",
		elementType: "geometry",
		stylers: [
		{ lightness: 100 },
		{ visibility: "simplified" }
		]
	}
	];
	map.setOptions({styles: styles});
}

google.maps.event.addDomListener(window, 'load', initMap);