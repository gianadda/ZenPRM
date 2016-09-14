'use strict'

angular
    .module('App.ConnectionController', [])
    .controller('ConnectionController', [
        '$scope',
        '$rootScope',
        '$log',
        '$filter',
        '$timeout',
        '$http',
        '$global',
        'RESTService',
        'growl',
        '$window',
        'identity',
        'LookupTablesService',
        'MyProfileService',
        '$stateParams',
        '$anchorScroll',
        '$location',
        function($scope, $rootScope, $log, $filter, $timeout, $http, $global, RESTService, growl, $window, identity, LookupTablesService, MyProfileService, $stateParams, $anchorScroll, $location) {

            $scope.LookupTables = LookupTablesService;
            $scope.tooltipEntity = {};

            //Vars for storing how we will search
            $scope.SearchGlobal = true;
            $scope.loadingEntities = false;
            $scope.loading = true;

            //scope vars for the values of the "New Connection"
            $scope.newConnectionToEntity;
            $scope.currentlySelectedToEntityIdent = 0;
            $scope.newConnectionType;
            $scope.currentlySelectedConnectionTypeIdent = 0;

            //scope vars to allow for limiting of the "ConnectionType" dropdown
            $scope.FromEntityTypeIdent = 0;


            //Var for the graphs
            var firstLoad = true;

            var mapHeight = 400;

            $scope.$watch("newConnectionToEntity", function() {

                if (angular.isObject($scope.newConnectionToEntity)) {
                    //There is an actual object

                    if ($scope.newConnectionToEntity.Ident !== $scope.currentlySelectedToEntityIdent) {
                        //The entity changed
                        $scope.currentlySelectedToEntityIdent = $scope.newConnectionToEntity.Ident;
                        $scope.ConnectionTypes = $scope.getConnectionTypes();
                        console.log('You have chosen a new "to Entity"');

                    } else if ($scope.currentlySelectedToEntityIdent == 0) {
                        //The entity has been chosen, for the old value was empty
                        $scope.currentlySelectedToEntityIdent = $scope.newConnectionToEntity.Ident;
                        $scope.ConnectionTypes = $scope.getConnectionTypes();
                        console.log('You have chosen a "To Entity"');

                    } else {
                        //The value is the same. Don't do anything    
                    }

                } else if ($scope.newConnectionToEntity) {
                    //The person is typing
                } else {
                    //The user cleared the typeahead, clear the "Selected Value"
                    $scope.currentlySelectedToEntityIdent = 0;
                    $scope.ConnectionTypes = $scope.getConnectionTypes();
                    console.log('You have cleared the To Entity"');

                }
            });

            $scope.$watch("newConnectionType", function() {

                if ($scope.newConnectionType) {
                    //There is an actual object
                    if ($scope.newConnectionType.Ident !== $scope.currentlySelectedConnectionTypeIdent) {
                        //The connection type changed
                        $scope.currentlySelectedConnectionTypeIdent = $scope.newConnectionType.Ident;
                        console.log('The ConnectionType has changed');

                    } else {
                        //The value is the same. Don't do anything    
                    }
                } else {
                    //The user cleared the dropdown (not doable in the interface)
                }

            });

            $scope.$watch("CurrentEntity.EntityNodes", function() {
                if ($scope.CurrentEntity) {
                    $scope.EntityType = $scope.CurrentEntity.Entity[0].EntityType;
                    $scope.FromEntityTypeIdent = $scope.CurrentEntity.Entity[0].EntityTypeIdent;
                    $scope.ConnectionTypes = $scope.getConnectionTypes();
                    if ($scope.CurrentEntity.EntityNodes && $scope.CurrentEntity.EntityEdges) {
                        $scope.SetupForceLayout();
                    }
                    $timeout(function() { //Set timeout
                        $scope.init();
                    });
                }
            });

            $scope.LoadEntity = function() {
                var ident = identity.getUserIdent();


                if ($stateParams.ident) {
                    ident = $stateParams.ident;
                }

                MyProfileService.getProfile(ident).then(function(pl) {
                        $scope.CurrentEntity = pl;

                        var entityNetworkGet = RESTService.get(RESTService.getControllerPath([$global.RESTControllerNames.COMMUNITYNETWORKMAP]), ident);


                        return entityNetworkGet.then(function(pl) {
                                $scope.CurrentEntity.EntityConnection = pl.data.EntityConnections;
                                $scope.CurrentEntity.EntityNodes = pl.data.EntityNodes;
                                $scope.CurrentEntity.EntityEdges = pl.data.EntityEdges;

                                $scope.loading = false;
                            },
                            function(errorPl) {

                                growl.error($global.GetRandomErrorMessage());
                            });

                    },
                    function(errorPl) {
                        // the following line rejects the promise 

                    });






            }


            $scope.getConnectionTypeDisplay = function(connectionType) {
                var textToDisplay = '';
                if (connectionType.FromEntityTypeIdent === $scope.FromEntityTypeIdent) {
                    textToDisplay = connectionType.Name1 + ' (' + connectionType.ToEntityTypeName1 + ')';
                } else if (connectionType.ToEntityTypeIdent === $scope.FromEntityTypeIdent) {
                    textToDisplay = connectionType.ReverseName1 + ' (' + connectionType.FromEntityTypeName1 + ')';

                }

                return textToDisplay


            }

            $scope.getConnectionTypes = function() {
                var connectionTypes = $filter('orderBy')($filter('filter')($scope.LookupTables.ConnectionType,
                    function(connectionType) {

                        //only show general connections, not "In Network" connections
                        var valid = (connectionType.IncludeInNetwork === false);

                        //only show general connections, not "Deleate" connections
                        valid = valid && (connectionType.Delegate === false);

                        //only show connection types that are allowed to come "from" this type of entity
                        valid = valid && ((connectionType.FromEntityTypeIdent === $scope.FromEntityTypeIdent) || (connectionType.ToEntityTypeIdent === $scope.FromEntityTypeIdent));

                        //If a "toEntity" has been selected limit the options to the ones for that side of the connection type
                        if ($scope.currentlySelectedToEntityIdent !== 0) {

                            if (connectionType.FromEntityTypeIdent === $scope.FromEntityTypeIdent) {

                                valid = valid && (connectionType.ToEntityTypeIdent === $scope.newConnectionToEntity.EntityTypeIdent);
                            } else if (connectionType.ToEntityTypeIdent === $scope.FromEntityTypeIdent) {
                                valid = valid && (connectionType.FromEntityTypeIdent === $scope.newConnectionToEntity.EntityTypeIdent);
                            }



                            // valid = valid && (connectionType.ToEntityTypeIdent === $scope.newConnectionToEntity.EntityTypeIdent);

                        }
                        return valid;
                    }

                ), "Name1");



                return connectionTypes;
            }


            //Ensure that there is a debounce on the typeing filter
            var timeoutPromise;
            var delayInMs = 1000;
            $scope.getEntities = function(val) {
                $scope.loadingEntities = true;
                $timeout.cancel(timeoutPromise); //does nothing, if timeout alrdy done
                timeoutPromise = $timeout(function() { //Set timeout
                    return $scope.getEntitiesNow(val);
                }, delayInMs);
                return timeoutPromise;
            };

            $scope.getEntitiesNow = function(val) {

                var ToEntityType = 0;
                if ($scope.currentlySelectedConnectionTypeIdent !== 0) {
                    //ToEntityType = $scope.newConnectionType.ToEntityTypeIdent;
                    if ($scope.newConnectionType.FromEntityTypeIdent === $scope.FromEntityTypeIdent) {
                        ToEntityType = $scope.newConnectionType.ToEntityTypeIdent;
                    } else if ($scope.newConnectionType.ToEntityTypeIdent === $scope.FromEntityTypeIdent) {
                        ToEntityType = $scope.newConnectionType.FromEntityTypeIdent;

                    }

                }


                var searchCriteria = [{
                    name: "keyword",
                    value: val
                }, {
                    name: "entityTypeIdent",
                    value: ToEntityType
                }, {
                    name: "entityIdent",
                    value: $scope.CurrentEntity.Entity[0].Ident
                }];

                var searchEntityGet;
                searchEntityGet = RESTService.getWithParams(RESTService.getControllerPath([$global.RESTControllerNames.SEARCHENTITYFORCONNECTION]), searchCriteria);

                return searchEntityGet.then(function(pl) {

                        return $filter('filter')(
                            pl.data.Entity.map(function(item) {
                                if (item.NPI) {

                                    item.DisplayName = item.FullName + ' (' + item.NPI + ')';

                                } else {

                                    item.DisplayName = item.FullName;

                                };

                                $scope.loadingEntities = false;
                                return item;
                            }),
                            function(item) {
                                if (item.Ident !== $scope.CurrentEntity.Entity[0].Ident) {
                                    return true;
                                }
                                return false;
                            });


                    },
                    function(errorPl) {

                    }
                );

            };

            $scope.removeConnection = function(ident) {
                var deleteEntityConnectionDelete;
                var postData = {
                    Ident: ident
                }
                deleteEntityConnectionDelete = RESTService.deleteIdentAsObject(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYCONNECTION]), postData);

                return deleteEntityConnectionDelete.then(function(pl) {

                        growl.success('OK! That connection has been removed.');

                        $scope.LoadEntity();
                    },
                    function(errorPl) {
                        growl.error($global.GetRandomErrorMessage());

                    }
                );

            }

            $scope.AddEntityConnection = function() {


                var CheckUnique = $filter('filter')($scope.CurrentEntity.EntityConnection,
                    function(item) {
                        if (item.ToEntityIdent == $scope.currentlySelectedToEntityIdent &&
                            item.ConnectionTypeIdent == $scope.currentlySelectedConnectionTypeIdent &&
                            $scope.newConnectionType.FromEntityTypeIdent === $scope.FromEntityTypeIdent) {
                            return true;
                        }
                        if (item.FromEntityIdent == $scope.currentlySelectedToEntityIdent &&
                            item.ConnectionTypeIdent == $scope.currentlySelectedConnectionTypeIdent &&
                            $scope.newConnectionType.ToEntityTypeIdent === $scope.FromEntityTypeIdent) {
                            return true;
                        }
                        return false;
                    });


                if (CheckUnique.length == 0) {
                    var postEntityConnectionPost;

                    if ($scope.newConnectionType.FromEntityTypeIdent === $scope.FromEntityTypeIdent) {
                        var postData = {
                            ConnectionTypeIdent: $scope.currentlySelectedConnectionTypeIdent,
                            FromEntityIdent: $scope.CurrentEntity.Entity[0].Ident,
                            ToEntityIdent: $scope.currentlySelectedToEntityIdent,
                            Active: true
                        }

                    } else {
                        var postData = {
                            ConnectionTypeIdent: $scope.currentlySelectedConnectionTypeIdent,
                            FromEntityIdent: $scope.currentlySelectedToEntityIdent,
                            ToEntityIdent: $scope.CurrentEntity.Entity[0].Ident,
                            Active: true
                        }

                    }

                    postEntityConnectionPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYCONNECTION]), postData);

                    return postEntityConnectionPost.then(function(pl) {

                            growl.success('Great! This connection has been added.');

                            $scope.newConnectionToEntity = undefined;
                            $scope.currentlySelectedToEntityIdent = 0;
                            $scope.LoadEntity();
                        },
                        function(errorPl) {
                            growl.error($global.GetRandomErrorMessage());

                        }
                    );
                } else {

                    growl.error('It looks like you already have that connection!');
                }
            }


            var force,
                w,
                h,
                links = [],
                nodes = [],
                toggle = 0; //Toggle stores whether the highlighting is on

            var fill = d3.scale.ordinal()
                .domain([
                    "System Administrator",
                    "Organization",
                    "Provider",
                    "Facility",
                    "IT Administrator",
                    "General Contact",
                    "Committee"
                ])
                .range([
                    "#ce605a", // system admin  = red
                    "#76689b", // organization  = purple
                    "#e29e0a", // provider      = orange
                    "#4ea66a", // facility      = green
                    "#67c0ce", // IT admin      = teal
                    "#d47ba7", // gen contact   = pink
                    "#5d8ca9" // committee     = blue
                ]);

            $scope.SetupForceLayout = function() {

                w = document.getElementById("NetworkMap").offsetWidth;
                h = mapHeight;
                //Take the $scope.CurrentEntity.EntityNodes and $scope.CurrentEntity.EntityEdges 
                // and make them into appropriate structures for the Layout
                nodes = $scope.CurrentEntity.EntityNodes;
                links = [];
                //Loop throught the Edges and do lookups to put the full source and target "Nodes" into the Edge object
                $scope.CurrentEntity.EntityEdges.forEach(function(e) {

                    var sourceNode = $scope.CurrentEntity.EntityNodes.filter(function(n) {
                        return n.NodeIdent === e.source;
                    })[0];

                    var targetNode = $scope.CurrentEntity.EntityNodes.filter(function(n) {
                        return n.NodeIdent === e.target;
                    })[0];

                    if (sourceNode && targetNode) {

                        links.push({
                            source: sourceNode,
                            target: targetNode,
                            value: e.value,
                            type: e.type,
                            name: e.name
                        });

                    }

                });

                //sort links by source, then target
                links.sort(function(a, b) {
                    if (a.source.NodeIdent > b.source.NodeIdent) {
                        return 1;
                    } else if (a.source.NodeIdent < b.source.NodeIdent) {
                        return -1;
                    } else {
                        if (a.target.NodeIdent > b.target.NodeIdent) {
                            return 1;
                        }
                        if (a.target.NodeIdent < b.target.NodeIdent) {
                            return -1;
                        } else {
                            return 0;
                        }
                    }
                });

                //any links with duplicate source and target get an incremented 'linknum', this is used to
                // make the lines have a slightly larger "arc" so that they don't overlap.
                for (var i = 0; i < links.length; i++) {
                    if (i != 0 &&
                        links[i].source.NodeIdent == links[i - 1].source.NodeIdent &&
                        links[i].target.NodeIdent == links[i - 1].target.NodeIdent) {
                        links[i].linknum = links[i - 1].linknum + 1;
                    } else {
                        links[i].linknum = 1;
                    };
                };

                //Clear the container and then put in an SVG
                d3.select("#forceContainer").selectAll("*").remove();
                var svg = d3.select("#forceContainer").append("svg")
                    .attr("width", w)
                    .attr("height", h)
                    //.call(responsivefy);

                //setup the defs
                svg.append("svg:defs")
                    .selectAll("marker")
                    .data(["link4", "link5", "link6", "link7", "end"])
                    .enter().append("svg:marker")
                    .attr("id", String)
                    .attr("viewBox", "0 -5 10 10")
                    .attr("refX", 15)
                    .attr("refY", -1.5)
                    .attr("markerWidth", 3)
                    .attr("markerHeight", 3)
                    .style("opacity", 0.8)
                    .attr("orient", "auto")
                    .append("svg:path")
                    .attr("d", "M0,-5L10,0L0,5");

                //now that we have the links defined, let's create the "path" cruves
                var curvedPaths = links.filter(function(n) {
                    return n.linknum >= 1;
                });

                //Create the Force Layout
                force = d3.layout.force()
                    .nodes(nodes)
                    .links(links)
                    .size([w, h])
                    .linkStrength(1)
                    .friction(0.9)
                    .linkDistance(function(d) {
                        //This is using the link's value
                        return d.value;
                    })
                    .charge(function(d) {
                        //This is using the node's value
                        return d.value * -400;
                    })
                    .gravity(0.2)
                    .theta(0.8)
                    .alpha(0.1)
                    .on("tick", tick)
                    .start();


                var drag = force.drag()
                    .on("dragstart", dragstart);

                var link = svg.append("svg:g").selectAll("path")
                    .data(curvedPaths)
                    .enter().append("svg:path")
                    .attr("opacity", 0.75)
                    .attr("class", function(d) {
                        return "link link" + d.type;
                    })
                    .attr("marker-end", function(d) {
                        return "url(#end)";
                    })
                    .on("mouseover", function(d) {
                        $scope.tooltipEntity = d;
                        $scope.$apply();
                    });

                var node = svg.append("svg:g").selectAll("circle")
                    .data(force.nodes())
                    .enter().append("svg:circle")
                    .attr("opacity", 0.75)
                    .attr("r", function(d, i) {
                        return d.value * 4;
                    })
                    .style("stroke", function(d, i) {
                        var strokeColor = fill(d.group);
                        if (d.CurrentCenterNode) {
                            strokeColor = "#4d5177";
                        }
                        return strokeColor;
                    })
                    .style("fill", function(d, i) {
                        return fill(d.group);
                    })
                    .on('click', function(d) {
                        connectedNodes(d);
                    })
                    .on("mouseover", function(d) {
                        $scope.tooltipEntity = d;
                        $scope.$apply();
                    })
                    .call(drag);

                //Legend
                var legend = svg.selectAll(".legend")
                    .data(fill.domain())
                    .enter().append("g")
                    .attr("class", "legend")
                    .attr("transform", function(d, i) {
                        return "translate(-20," + (i+1) * 20 + ")";
                    });

                legend.append("rect")
                    .attr("x", w - 18)
                    .attr("width", 18)
                    .attr("height", 18)
                    .style("fill", fill);

                legend.append("text")
                    .attr("x", w - 24)
                    .attr("y", 9)
                    .attr("dy", ".35em")
                    .style("text-anchor", "end")
                    .text(function(d) {
                        return d;
                    });


                //Create an array logging what is connected to what
                var linkedByIndex = {};
                for (i = 0; i < force.nodes.length; i++) {
                    linkedByIndex[i + "," + i] = 1;
                };
                force.links().forEach(function(d) {
                    linkedByIndex[d.source.index + "," + d.target.index] = 1;
                });


                function tick(e) {
                    var r = 6;

                    node.attr("cx", function(d) {
                            return d.x = Math.max(r, Math.min(w - r, d.x));
                        })
                        .attr("cy", function(d) {
                            return d.y = Math.max(r, Math.min(h - r, d.y));
                        });

                    link.attr("x1", function(d) {
                            return d.source.x;
                        })
                        .attr("y1", function(d) {
                            return d.source.y;
                        })
                        .attr("x2", function(d) {
                            return d.target.x;
                        })
                        .attr("y2", function(d) {
                            return d.target.y;
                        });

                    link.attr("d", function(d) {
                        var dx = d.target.x - d.source.x,
                            dy = d.target.y - d.source.y,
                            dr = 500 / d.linknum; //linknum is defined above
                        return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
                    });
                }

                function dragstart(d) {
                    d3.select(this).classed("fixed", d.fixed = true);
                }

                //This function looks up whether a pair are neighbours  
                function neighboring(a, b) {
                    return linkedByIndex[a.index + "," + b.index];
                }

                function connectedNodes(d) {

                    if (toggle == 0) {
                        //Reduce the opacity of all but the neighbouring nodes
                        node.style("opacity", function(o) {
                            var highlighted = neighboring(d, o) | neighboring(o, d) ? 1 : 0.1;
                            if (o.NodeIdent == d.NodeIdent) {
                                highlighted = true;
                            }
                            return highlighted;
                        });

                        link.style("opacity", function(o) {
                            return d.index == o.source.index | d.index == o.target.index ? 1 : 0.1;
                        });

                        //Reduce the op
                        toggle = 1;
                    } else {
                        //Put them back to opacity=1
                        node.style("opacity", .75);
                        link.style("opacity", .75);
                        toggle = 0;
                    }

                }

            }

            var timeoutPromise;
            var delayInMsResize = 250;

            window.onresize = function() {

                // Resize SVG
                w = document.getElementById("NetworkMap").offsetWidth;
                h = mapHeight;
                var svg = d3.select("#forceContainer").select("svg")
                    .attr("width", w)
                    .attr("height", h);

                // Reposition legend
                var legend = svg.selectAll(".legend");
                legend.selectAll("rect").attr("x", w - 18);
                legend.selectAll("text").attr("x", w - 24);

                // Re-flow SVG nodes
                $timeout.cancel(timeoutPromise); //does nothing, if timeout already done

                timeoutPromise = $timeout(function() { //Set timeout
                    force.stop();
                    force.start();
                    return true;

                }, delayInMsResize);

            }

            $scope.init = function() {
                if ($stateParams.key) {
                    $location.hash($stateParams.key);

                    // call $anchorScroll()
                    $anchorScroll();
                }
            }


            $scope.LoadEntity();




        }
    ])
    .directive('typeahead', function() {
        return {
            require: 'ngModel',
            link: function(scope, element, attr, ctrl) {
                element.bind('click', function() {
                    if (angular.isDefined(ctrl.$viewValue)) {
                        if (ctrl.$viewValue.trim() == '') {
                            ctrl.$setViewValue(ctrl.$viewValue + ' ');
                        }
                    } else {
                        ctrl.$setViewValue(' ');
                    }

                });
            }
        };
    });
