angular.module('App.ResourcesMapDirective', [])
    .directive('resourcesMap', function() {

        return {
            restrict: 'E',
            templateUrl: 'Resources/resources-map.html',
            controller: function($global, $rootScope, $scope, growl, $timeout, RESTService, $state) {
                $scope.center = {};
                $scope.center.zoom = 14;
                $scope.mapDataReady = false;
                $scope.UnmapableResourcesCount = 0;

                $scope.Map = L.map('map');

                var centerMarker;
                var cssIcon = L.divIcon({
                    // Specify a class name we can refer to in CSS.
                    className: 'center-point',
                    // Set marker width and height
                    iconSize: [15, 15]
                });

                $scope.pruneCluster = new PruneClusterForLeaflet();

                $scope.FindUnMapped = function() {

                    $rootScope.searchCriteria.location = '';
                    $rootScope.searchCriteria.latitude = 1.00000;
                    $rootScope.searchCriteria.longitude = 1.00000;
                    $rootScope.searchCriteria.radius = 'Unknown';
                    $state.go('site.Resources', { Tab: 'grid' });

                }

                /*$scope.tilesDict = {
                    openstreetmap: {
                        url: "http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                        options: {
                            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
                        }
                    },
                    opencyclemap: {
                        url: "http://{s}.tile.opencyclemap.org/cycle/{z}/{x}/{y}.png",
                        options: {
                            attribution: 'All maps &copy; <a href="http://www.opencyclemap.org">OpenCycleMap</a>, map data &copy; <a href="http://www.openstreetmap.org">OpenStreetMap</a> (<a href="http://www.openstreetmap.org/copyright">ODbL</a>'
                        }
                    },
                    openstreetmap_blackandwhite: {
                        url: 'http://{s}.tiles.wmflabs.org/bw-mapnik/{z}/{x}/{y}.png',
                        options: {
                            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>'
                        }
                    },
                    cartodb_Positron: {
                        url: 'https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png',
                        options: {
                            attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>'
                        }
                    }
                };
                //Positron --http://cartodb.com/basemaps
                */

                $scope.$on('SearchProcessBegins', function(args) {
                    $scope.loading = true;
                });

                $scope.$on('SearchComplete', function(args) {

                    $scope.setHeight('map');
                    $scope.UnmapableResourcesCount = 0;
                    if ($scope.searchCriteria.latitude && $scope.searchCriteria.latitude !== 0.0 && $scope.searchCriteria.longitude && $scope.searchCriteria.longitude !== 0.0) {
                        $scope.center.lat = $scope.searchCriteria.latitude;
                        $scope.center.lng = $scope.searchCriteria.longitude;
                    } else {
                        if ($scope.CurrentEntity) {
                            $scope.center.lat = $scope.CurrentEntity.Entity[0].Latitude;
                            $scope.center.lng = $scope.CurrentEntity.Entity[0].Longitude;
                        } else {
                            //Who knows?!?! Center of US
                            $scope.center.lat = 39.8282;
                            $scope.center.lng = -98.5795;

                        }
                    }



                    if (centerMarker) {
                        $scope.Map.removeLayer(centerMarker);
                    }
                    centerMarker = L.marker([$scope.center.lat, $scope.center.lng], { icon: cssIcon }).addTo($scope.Map);
                    centerMarker.bindPopup('Center: ' + $rootScope.searchCriteria.location);
                    $scope.Map.setView($scope.center, $scope.center.zoom);
                    // Remove all the markers
                    $scope.pruneCluster.RemoveMarkers();

                    L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
                        attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
                        minZoom: 4
                    }).addTo($scope.Map);

                    var myIcon = L.icon({
                        iconUrl: '/assets/img/leaflet/marker-icon.png',
                        shadowUrl: '/assets/img/leaflet/marker-shadow.png',
                        iconSize: [25, 41], // size of the icon
                        shadowSize: [41, 41], // size of the shadow
                        iconAnchor: [12, 41], // point of the icon which will correspond to marker's location
                        shadowAnchor: [12, 41], // the same for the shadow
                        popupAnchor: [0, -41] // point from which the popup should open relative to the iconAnchor
                    });
                    var marker;
                    for (var i = 0; i < $scope.searchResults.length; i++) {
                        if ($scope.searchResults[i].lat !== 0 && $scope.searchResults[i].lng !== 0) {
                            marker = new PruneCluster.Marker($scope.searchResults[i].lat, $scope.searchResults[i].lng);
                            marker.data.icon = myIcon;
                            marker.data.popup = '<p><strong>' + $scope.searchResults[i].DisplayName + '</strong>';
                            if ($scope.searchResults[i].NPI != '') {
                                marker.data.popup = marker.data.popup + '<br>' + $scope.searchResults[i].NPI + '</p>';
                            } else {
                                marker.data.popup = marker.data.popup + '</p>'
                            }

                            if ($scope.searchResults[i].PrimaryAddress1 != '') {
                                marker.data.popup = marker.data.popup + '<p>' + $scope.searchResults[i].PrimaryAddress1;

                                if ($scope.searchResults[i].PrimaryAddress2 != '') {
                                    marker.data.popup = marker.data.popup + '<br>' + $scope.searchResults[i].PrimaryAddress2;
                                }
                                if ($scope.searchResults[i].PrimaryAddress3 != '') {
                                    marker.data.popup = marker.data.popup + '<br>' + $scope.searchResults[i].PrimaryAddress3;
                                }
                                if ($scope.searchResults[i].PrimaryCity != '' && $scope.searchResults[i].PrimaryState != '' && $scope.searchResults[i].PrimaryZip != '') {
                                    marker.data.popup = marker.data.popup + '<br>' + $scope.searchResults[i].PrimaryCity + ', ';
                                    marker.data.popup = marker.data.popup + $scope.searchResults[i].PrimaryState + ' ';
                                    marker.data.popup = marker.data.popup + $scope.searchResults[i].PrimaryZip;
                                }

                                marker.data.popup = marker.data.popup + '</p>';
                            }

                            marker.category = $scope.searchResults[i].EntityType;

                            $scope.pruneCluster.RegisterMarker(marker);

                        } else {
                            $scope.UnmapableResourcesCount = $scope.UnmapableResourcesCount + 1;
                        }


                    }

                    $scope.Map.addLayer($scope.pruneCluster);
                    $scope.pruneCluster.FitBounds();

                    $scope.loading = false;

                    //$scope.Map.setView($scope.center, $scope.Map.getZoom());

                })

                function createIcon(data, category) {
                    var myIcon = L.icon({
                        iconUrl: '/assets/img/leaflet/marker-icon.png',
                        iconRetinaUrl: '/assets/img/leaflet/marker-icon-2x.png'
                    });
                    return L.icon(L.Icon.Default);
                }

                $scope.Map.off('dblclick');

                $scope.Map.on('dblclick', function(e) {
                    $rootScope.searchCriteria.location = e.latlng.lat.toFixed(6) + ' ' + e.latlng.lng.toFixed(6);
                    $rootScope.searchCriteria.latitude = e.latlng.lat;
                    $rootScope.searchCriteria.longitude = e.latlng.lng;
                    if ($rootScope.searchCriteria.radius == '') {
                        $rootScope.searchCriteria.radius = 5;
                    }
                    $scope.search();
                });

                $scope.getMeters = function(i) {
                    return i * 1609.344;
                }

                window.onresize = function() {
                    $scope.setHeight('map');
                }

            }
        };
    });
