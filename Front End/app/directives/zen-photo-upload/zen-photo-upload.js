angular.module('App.zenPhotoUpload', ['ngImgCrop'])
.directive('zenPhotoUpload', function() {
  return {
    restrict: 'E',
    scope: {
        photo: '=',
        imageSize: '@',
        imageQuality: '@'
    },
    templateUrl: 'directives/zen-photo-upload/zen-photo-upload.html',
    controller: function ($scope, $modal) {

        $scope.originalPhoto = '';
        $scope.croppedPhoto = '';

        $scope.updatePhoto = function(newImage){

            //if we have an original Photo, we've uploaded and cropped the photo
            if ($scope.originalPhoto){

                $scope.photo = newImage;

            };

        };

        var handleFileSelect = function(evt) {

            var file = evt.currentTarget.files[0];
            var reader = new FileReader();

            reader.onload = function (evt) {

                $scope.$apply(function($scope){

                    $scope.originalPhoto = evt.target.result;
                    
                });
            };

            reader.readAsDataURL(file);

            $scope.CropModal = $modal.open({
                animation: true,
                templateUrl: 'ImgCrop.html',
                size: 'lg',
                scope: $scope,
            });

        }; // handleFileSelect


        angular.element(document.querySelector('#photoUpload')).on('change', handleFileSelect);

    }

  };

});