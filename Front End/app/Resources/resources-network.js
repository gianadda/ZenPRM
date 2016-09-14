angular.module('App.ResourcesNetworkDirective', [])
    .directive('resourcesNetwork', function() {

        return {
            restrict: 'E',
            templateUrl: 'Resources/resources-network.html',

            controller: function($global, $rootScope, $scope, growl, $timeout, RESTService, $filter, identity) {

                    $scope.CurrentEntity = {
                        EntityNodes: [],
                        EntityEdges: []
                    }



                    $scope.$on('TimeToStartTheSearch', function(args) {
                        if (!$scope.loading) {
                            $scope.GetNetworkData();
                        }
                    })


                    $scope.IsCustomer = function() {
                        return $global.isCustomer();
                    }
                    $scope.IsMyProfile = function(ident) {
                        var bolValid = false;
                        if (identity.getUserIdent() === ident) {
                            bolValid = true;
                        }

                        return bolValid;
                    }



                    $scope.addToNetwork = function(ident) {
                        var putData = {
                            Ident: ident,
                            Active: true
                        };

                        var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ADDENTITYTONETWORK]), putData);

                        return editPost.then(function(pl) {
                                var bolSuccess = false;

                                if (pl.data.length > 0) {

                                    if (pl.data[0].Ident !== 0) {

                                        growl.success($global.GetRandomSuccessMessage());

                                    }
                                }

                                return bolSuccess;
                            },
                            function(errorPl) {

                                growl.error($global.GetRandomErrorMessage());
                                return false;
                            });

                    }

                    $scope.removeFromNetwork = function(ident) {
                        var putData = {
                            EntityIdent: ident
                        };

                        var editPost = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.REMOVEENTITYFROMNETWORK]), putData);

                        editPost.then(function(pl) {

                                if (pl.status === 400) {
                                    growl.error(pl.data);

                                } else {
                                    growl.success($global.GetRandomSuccessMessage());

                                }
                            },
                            function(errorPl) {
                                growl.error($global.GetRandomErrorMessage());
                            });

                    }



                    $scope.GetNetworkData = function() {

                        $scope.loading = true;


                        if ($rootScope.searchCriteria.radius == 'Unknown') {
                            $rootScope.searchCriteria.location = '';
                            $rootScope.searchCriteria.latitude = 1.00000;
                            $rootScope.searchCriteria.longitude = 1.00000;
                        }
                        var LastSecondSearchCriteria;
                        LastSecondSearchCriteria = angular.copy($rootScope.searchCriteria);
                        if (LastSecondSearchCriteria.radius == 'Unknown') {
                            LastSecondSearchCriteria.radius = 100;
                        }


                        var postEntitySearch = RESTService.post(RESTService.getControllerPath([$global.RESTControllerNames.ENTITYSEARCH]) + '/Network', LastSecondSearchCriteria);

                        postEntitySearch.then(function(pl) {

                                $scope.CurrentEntity.EntityNodes = pl.data.nodes;
                                $scope.CurrentEntity.EntityEdges = pl.data.links;


                                if (pl.data && pl.data.ResultCounts) {

                                    $rootScope.searchResultsTotal = pl.data.ResultCounts[0].TotalResults;

                                } else {

                                    // something happened, return 0 results
                                    $rootScope.searchResultsTotal = 0;
                                };

                                $scope.setHeight('forceContainer');
                                $scope.SetupForceLayout();

                                $scope.loading = false;
                                $scope.fullScreenLoading = false;

                            },
                            function(errorPl) {
                                growl.error($global.GetRandomErrorMessage());
                                $scope.loading = false;
                                $scope.fullScreenLoading = false;
                            });


                    };

                    // ### NETWORK MAP SETUP ### //

                    var svg,
                        force,
                        w,
                        h,
                        links = [],
                        nodes = [],
                        toggle = 0,
                        angle = 0; //Toggle stores whether the highlighting is on

                    var fill = d3.scale.ordinal()
                        .domain([])
                        .range([
                            "#ce605a", // = red
                            "#76689b", // = purple
                            "#e29e0a", // = orange
                            "#4ea66a", // = green
                            "#67c0ce", // = teal
                            "#d47ba7", // = pink
                            "#5d8ca9" //  = blue
                        ]);

                    $scope.SetupForceLayout = function() {

                        w = document.getElementById("NetworkMap").offsetWidth;
                        h = $scope.mapHeight;
                        links = [];
                        nodes = [];
                        angle = 0;

                        $scope.tooltipEntity = undefined;

                        //Take the $scope.CurrentEntity.EntityNodes and $scope.CurrentEntity.EntityEdges 
                        // and make them into appropriate structures for the Layout
                        nodes = $scope.CurrentEntity.EntityNodes;
                        var totalNodes = nodes.length;

                        $scope.CurrentEntity.EntityNodes.forEach(function(e) {


                            if (totalNodes >= 200) {
                                angle = angle + 1;
                                e.fixed = true;
                                e.x = w / 2 + ((1 / e.value) * 200 + (angle * 5)) * Math.cos(angle);
                                e.y = h / 2 + ((1 / e.value) * 200 + (angle * 5)) * Math.sin(angle);
                            }



                            if (e.CurrentCenterNode) {

                                e.fixed = true;
                                e.x = w / 2;
                                e.y = h / 2;
                            }
                        });

                        //Loop throught the Edges and do lookups to put the full source and target "Nodes" into the Edge object
                        $scope.CurrentEntity.EntityEdges.forEach(function(e) {

                            var sourceNode = $scope.CurrentEntity.EntityNodes.filter(function(n) {
                                return n.NodeIdent === e.source;
                            })[0];

                            var targetNode = $scope.CurrentEntity.EntityNodes.filter(function(n) {
                                return n.NodeIdent === e.target;
                            })[0];
                            e.source = sourceNode;
                            e.target = targetNode;


                            if (sourceNode && targetNode) {
                                links.push(e)
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
                        svg = d3.select("#forceContainer").append("svg")
                            .attr("width", w)
                            .attr("height", h)
                            .attr("pointer-events", "all")
                            .append('svg:g')
                            .call(d3.behavior.zoom().on("zoom", redraw))
                            .append('svg:g');

                        //setup the defs
                        svg.append("svg:defs")
                            .selectAll("marker")
                            .data(["link4", "link5", "link6", "link7", "end"])
                            .enter().append("svg:marker")
                            .attr("id", String)
                            .attr("viewBox", "0 0 10 10")
                            .attr("refX", 15)
                            .attr("refY", -1.5)
                            .attr("markerWidth", 3)
                            .attr("markerHeight", 3)
                            .style("opacity", 0.8)
                            .attr("orient", "auto")
                            .append("svg:path")
                            //.attr("d", "M0,-5L10,0L0,5");

                        //now that we have the links defined, let's create the "path" cruves
                        var curvedPaths = links.filter(function(n) {
                            return n.linknum >= 1;
                        });


                        //Create the Force Layout
                        force = d3.layout.force()
                            .nodes(nodes)
                            .links(links)
                            .size([w, h])
                            .charge(function(d) {
                                var charge = -700;
                                charge = d.value * charge;
                                return charge;
                            })
                            .linkDistance(function(d) {
                                //This is using the link's value
                                return d.value;
                            })
                            .linkStrength(function(d) {
                                //This is using the link's value
                                return (1 - (1 / d.value));
                            })
                            .friction(0.1)
                            .gravity(.1)
                            .theta(0.8)
                            .on("tick", tick)
                            .start();

                        var drag = force.drag()
                            .on("dragstart", dragstart);

                        var link = svg.append("svg:g").selectAll("path")
                            .data(curvedPaths)
                            .enter().append("svg:path")
                            .attr("opacity", function(d) {
                                var opa = 0.75

                                if (totalNodes >= 200) {
                                    opa = 0;
                                }
                                return opa;
                            })
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
                                var size = d.value;
                                if (totalNodes <= 100) {
                                    size = d.value * 4;
                                } else if (totalNodes > 100 && totalNodes < 400) {
                                    size = d.value;
                                } else if (totalNodes > 400 && totalNodes < 1500) {
                                    size = d.value / 2;
                                } else if (totalNodes > 1500) {
                                    size = d.value / 4;
                                }
                                return size;
                            })
                            .style("stroke", function(d, i) {
                                var strokeColor = "#666"; //fill(d.group);
                                if (d.CurrentCenterNode) {
                                    strokeColor = "#666";
                                }
                                return strokeColor;
                            })
                            .style("fill", function(d, i) {
                                return fill(d.group);
                            })
                            .attr("id", function(d) {
                                if (d.CurrentCenterNode) {
                                    return "CenterPoint";
                                }
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
                                return "translate(-20," + (i + 1) * 20 + ")";
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


                        //This works pretty well.
                        //https://gist.github.com/DavidBruant/6489486

                        var placedItems = 0;

                        function tick(e) {

                            if (placedItems == 0 || totalNodes <= 400) {
                                placedItems = 1;

                                var r = 30;
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
                                        dr = 100; //linknum is defined above

                                    if (dx > 50) {
                                        dr = 2000;
                                    } else if (dx < -50) {
                                        dr = 2000;
                                    }
                                    if (dy > 50) {
                                        dr = 3000;
                                    } else if (dy < -50) {
                                        dr = 3000;
                                    }

                                    return "M" + d.source.x + "," + d.source.y + "A" + dr + "," + dr + " 0 0,1 " + d.target.x + "," + d.target.y;
                                });
                            }

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
                                    return d.index == o.source.index | d.index == o.target.index ? 1 : 0;
                                });

                                //Reduce the op
                                toggle = 1;
                            } else {
                                //Put them back to opacity=1
                                node.style("opacity", .75);
                                link.style("opacity", 0);
                                toggle = 0;
                            }

                        }

                    }

                    function redraw() {
                        console.log("here", d3.event.translate, d3.event.scale);
                        svg.attr("transform",
                            "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")");
                    }


                    var timeoutPromise;
                    var delayInMsResize = 250;

                    window.onresize = function() {
                        // Set container height
                        $scope.setHeight('forceContainer');

                        // Resize SVG
                        w = document.getElementById("NetworkMap").offsetWidth;
                        h = $scope.mapHeight;
                        var svg = d3.select("#forceContainer").select("svg")
                            .attr("width", w)
                            .attr("height", h);

                        // Reposition legend
                        var legend = svg.selectAll(".legend");
                        legend.selectAll("rect").attr("x", w - 18);
                        legend.selectAll("text").attr("x", w - 24);



                    }; // on resize

                    $scope.GetNetworkData();

                } // controller

        } // return
    });
