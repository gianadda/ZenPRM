angular.module('App.ResourcesMapGlobalDirective', [])
    .directive('resourcesMapGlobal', function() {

        return {
            restrict: 'E',
            templateUrl: 'Resources/resources-map-global.html',
            controller: function($global, $rootScope, $scope, growl, $timeout, RESTService, $state) {
                $scope.center = {};
                $scope.center.zoom = 14;
                $scope.mapDataReady = false;
                $scope.UnmapableResourcesCount = 0;

                $scope.CancelSearch = false;
                $scope.RecordsLoadedSoFar = 0;
                $scope.TotalNumberOfPagesNeeded = 0;
                $scope.TotalNumberOfPagesRequestedSoFar = 0;
                $scope.TotalNumberOfPagesLoadedSoFar = 0;
                $rootScope.searchCriteria.SortByIdent = true;
                $scope.CurrentMaxIdent = 0;

                //$scope.Map = L.map('map');
                var map = L.map("map");

                L.tileLayer('https://cartodb-basemaps-{s}.global.ssl.fastly.net/light_all/{z}/{x}/{y}.png', {
                    attribution: '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors, &copy; <a href="http://cartodb.com/attributions">CartoDB</a>',
                    minZoom: 4
                }).addTo(map);

                var leafletView = new PruneClusterForLeaflet();
                var markers = [];
                var centerMarker;
                var cssIcon = L.divIcon({
                    // Specify a class name we can refer to in CSS.
                    className: 'center-point',
                    // Set marker width and height
                    iconSize: [15, 15]
                });
                var myIcon = L.icon({
                    iconUrl: '/assets/img/leaflet/marker-icon.png',
                    shadowUrl: '/assets/img/leaflet/marker-shadow.png',
                    iconSize: [25, 41], // size of the icon
                    shadowSize: [41, 41], // size of the shadow
                    iconAnchor: [12, 41], // point of the icon which will correspond to marker's location
                    shadowAnchor: [12, 41], // the same for the shadow
                    popupAnchor: [0, -41] // point from which the popup should open relative to the iconAnchor
                });
                /*
                                $scope.FindUnMapped = function() {

                                    $rootScope.searchCriteria.location = '';
                                    $rootScope.searchCriteria.latitude = 1.00000;
                                    $rootScope.searchCriteria.longitude = 1.00000;
                                    $rootScope.searchCriteria.radius = 'Unknown';
                                    $state.go('site.Resources', { Tab: 'grid' });

                                }
                */

                $scope.drawComplete = function() {
                    var percent = 0;

                    if ($scope.TotalNumberOfPagesNeeded !== 0) {
                        percent = (100 / $scope.TotalNumberOfPagesNeeded) * $scope.TotalNumberOfPagesLoadedSoFar;
                    }

                    return parseInt(percent) + '%';
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

                function determineZoomByRadius(radius) {

                    var zoom = 4;
                    if (radius == 1) {
                        zoom = 13;
                    } else if (radius == 5) {
                        zoom = 12;
                    } else if (radius == 10) {
                        zoom = 11;
                    } else if (radius == 25) {
                        zoom = 9;
                    } else if (radius == 50) {
                        zoom = 8;
                    } else if (radius == 100) {
                        zoom = 7;
                    } else if (radius == 250) {
                        zoom = 6;
                    } else if (radius == 500) {
                        zoom = 6;
                    }
                    return zoom;
                }

                $scope.$on('SearchProcessBegins', function(args) {
                    $scope.loading = true;
                });

                $scope.$on('SearchComplete', function(args) {
                    $scope.loading = true;

                    $scope.setHeight('map');
                    $scope.UnmapableResourcesCount = 0;
                    $scope.RecordsLoadedSoFar = 0;
                    $rootScope.searchCriteria.SkipToIdent = 0;
                    $scope.CurrentMaxIdent = 0;

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
                        map.removeLayer(centerMarker);
                    }
                    centerMarker = L.marker([$scope.center.lat, $scope.center.lng], { icon: cssIcon }).addTo(map);
                    centerMarker.bindPopup('Center: ' + $rootScope.searchCriteria.location);
                    map.setView($scope.center, determineZoomByRadius($rootScope.searchCriteria.radius));

                    //50000 is the max returned in one shot
                    $scope.TotalNumberOfPagesNeeded = ($scope.searchResultsTotal / 50000 + 1).toFixed(0);
                    $scope.TotalNumberOfPagesLoadedSoFar = 1;
                    $scope.TotalNumberOfPagesRequestedSoFar = 1;

                    map.addLayer(leafletView);


                    //$rootScope.searchCriteria.radius
                    /*                    var circle = L.circleMarker([$scope.searchCriteria.latitude, $scope.searchCriteria.longitude], 5000, {
                                            color: 'red',
                                            fillColor: '#f03',
                                            fillOpacity: 0.5
                                        }); //.addTo(map);
                                        map.addLayer(circle);*/

                    // Remove all the markers
                    leafletView.RemoveMarkers();
                    //leafletView.Cluster.Size = 10;


                    $scope.LoadMarkers($scope.searchResults);
                    $scope.RecordsLoadedSoFar = $scope.searchResults.length;

                    if ($scope.RecordsLoadedSoFar == $rootScope.searchResultsTotal) {
                        leafletView.ProcessView();
                        $scope.loading = false;
                    }

                    $scope.BufferedLoad();

                })


                $scope.BufferedLoad = function() {
                    var count = 1;
                    if ($scope.TotalNumberOfPagesLoadedSoFar == $scope.TotalNumberOfPagesRequestedSoFar) {
                        while ($scope.TotalNumberOfPagesNeeded - $scope.TotalNumberOfPagesRequestedSoFar !== 0 && count <= 1) {

                            $timeout(function(i) {
                                $scope.ContinueSearch();
                            }, 0);
                            $scope.TotalNumberOfPagesRequestedSoFar++;
                            count++;
                        }
                    }

                    if ($scope.TotalNumberOfPagesNeeded - $scope.TotalNumberOfPagesRequestedSoFar !== 0) {
                        if (!$scope.CancelSearch) {
                            $timeout(function(i) {
                                $scope.BufferedLoad();
                            }, 100);
                        } else {
                            $scope.TotalNumberOfPagesNeeded = $scope.TotalNumberOfPagesLoadedSoFar;
                            $scope.CancelSearch = false;
                            leafletView.ProcessView();
                            $scope.loading = false;
                        }

                    }

                }


                $scope.ContinueSearch = function() {

                    //markers

                    $rootScope.searchCriteria.SkipToIdent = $scope.CurrentMaxIdent
                    $rootScope.searchCriteria.SortByIdent = true
                        // if ($scope.TotalNumberOfPagesNeeded - $scope.TotalNumberOfPagesLoadedSoFar !== 0) {
                    var postEntitySearch = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]), $rootScope.searchCriteria);
                    postEntitySearch.then(function(pl, r) {
                        $scope.TotalNumberOfPagesLoadedSoFar++;
                        $scope.RecordsLoadedSoFar += pl.data.Entities.length;
                        $scope.LoadMarkers(pl.data.Entities);

                    })

                }

                $scope.LoadMarkers = function(data) {


                    for (var i = 0; i < data.length; i++) {
                        if (data[i].lat !== 0 && data[i].lng !== 0) {
                            if (data[i].Ident > $scope.CurrentMaxIdent) {
                                $scope.CurrentMaxIdent = data[i].Ident;
                            }
                            if (data[i].Ident >= 509332) {
                                $scope.CurrentMaxIdent = $scope.CurrentMaxIdent;
                            }

                            var marker = new PruneCluster.Marker(parseFloat(data[i].lat), parseFloat(data[i].lng));

                            marker.data.popup = '<p><strong>' + data[i].DisplayName + '</strong>';
                            marker.data.Ident = data[i].Ident;
                            if (data[i].NPI != '') {
                                marker.data.popup = marker.data.popup + '<br>' + data[i].NPI + '</p>';
                            } else {
                                marker.data.popup = marker.data.popup + '</p>'
                            }

                            if (data[i].PrimaryAddress1 != '') {
                                marker.data.popup = marker.data.popup + '<p>' + data[i].PrimaryAddress1;

                                if (data[i].PrimaryAddress2 != '') {
                                    marker.data.popup = marker.data.popup + '<br>' + data[i].PrimaryAddress2;
                                }
                                if (data[i].PrimaryAddress3 != '') {
                                    marker.data.popup = marker.data.popup + '<br>' + data[i].PrimaryAddress3;
                                }
                                if (data[i].PrimaryCity != '' && data[i].PrimaryState != '' && data[i].PrimaryZip != '') {
                                    marker.data.popup = marker.data.popup + '<br>' + data[i].PrimaryCity + ', ';
                                    marker.data.popup = marker.data.popup + data[i].PrimaryState + ' ';
                                    marker.data.popup = marker.data.popup + data[i].PrimaryZip;
                                }

                                marker.data.popup = marker.data.popup + '</p>';
                            }

                            marker.category = data[i].EntityTypeIdent;

                            leafletView.RegisterMarker(marker);



                        } else {
                            $scope.UnmapableResourcesCount = $scope.UnmapableResourcesCount + 1;
                        }
                    }


                    if ($scope.RecordsLoadedSoFar == $rootScope.searchResultsTotal) {
                        leafletView.ProcessView();
                        $scope.loading = false;
                    }


                };

                map.off('dblclick');

                map.on('dblclick', function(e) {
                    $rootScope.searchCriteria.location = e.latlng.lat.toFixed(6) + ' ' + e.latlng.lng.toFixed(6);
                    $rootScope.searchCriteria.latitude = e.latlng.lat;
                    $rootScope.searchCriteria.longitude = e.latlng.lng;
                    $scope.search();
                });

                leafletView.PrepareLeafletMarker = function(leafletMarker, data) {
                    leafletMarker.setIcon(myIcon); // See http://leafletjs.com/reference.html#icon
                    //listeners can be applied to markers in this function
                    leafletMarker.on('dblclick', function() {
                        //do click event logic here

                        $state.go('site.Profile', { ident: data.Ident });
                    });
                    // A popup can already be attached to the marker
                    // bindPopup can override it, but it's faster to update the content instead
                    if (leafletMarker.getPopup()) {
                        leafletMarker.setPopupContent(data.popup);
                    } else {
                        leafletMarker.bindPopup(data.popup);
                    }
                };

                $scope.getMeters = function(i) {
                    return i * 1609.344;
                }

                window.onresize = function() {
                    $scope.setHeight('map');
                }

            }
        };
    });
