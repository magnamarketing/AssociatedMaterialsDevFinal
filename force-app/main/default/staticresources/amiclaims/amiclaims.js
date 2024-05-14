'use strict';
(function($) {
    // global namespace
    window.APP_ASSOCIATED_MATERIALS = {
        accountId: $('input#accountId').val(),
        appAssociatedMaterials: angular.module('appAssociatedMaterials', ['ngSanitize']),
        contactId: $('input#contactId').val(),
        hasAttachment: false,
        lastClaimId: '',
        propertyOwnerId: $('input#propertyOwnerId').val(),
        staticResourcePath: '',
        userId: $('input#userId').val()
    }

    // set timeout at page level to maximum of 120000 (120 seconds)
    Visualforce.remoting.timeout = 120000;

    // native JavaScript functions
    function initGeocomplete() {
        $('input#geocomplete').geocomplete({
            map: '#map-canvas',
            details: '#map-details'
        }).bind('geocode:result', function(event, result) {
            // https://stackoverflow.com/questions/15424910/angularjs-access-scope-from-outside-js-function
            var scope = angular.element('#geocomplete').scope();
            scope.$apply(function() {
                scope.showNewPropertyForm = false;
            });
        });
    }

    function initGeocompleteUpdateClaim() {
        $('input#claim-address-update').geocomplete({
            map: '#map-canvas',
            details: '#map-details'
        });
    }

    function setFocusFirstNameSiding() {
        $('input#serial-number-siding').val('').focus();
    }

    function openWindowClaimModal() {
        $('div#modal-window-claim').modal('show');
    }

    function closeWindowClaimModal() {
        $('div#modal-window-claim').modal('hide');
    }

    function openModalSelectProperty() {
        $('div#modal-select-property').modal('show');
    }

    function closeModalSelectProperty() {
        $('div#modal-select-property').modal('hide');
    }

    function openModalSelectClaim() {
        $('div#modal-claims').modal('show');
    }

    function closeModalSelectClaim() {
        $('div#modal-claims').modal('hide');
    }

    function openModalConfirmProperty() {
        $('div#modal-confirm-property').modal('show');
    }

    function closeModalConfirmProperty() {
        $('div#modal-confirm-property').modal('hide');
    }

    function openModalUpdateClaim() {
        $('div#modal-update-claim').modal('show');
    }

    function closeModalUpdateClaim() {
        $('div#modal-update-claim').modal('hide');
    }

    function openModalAddFiles() {
        $('div#modal-add-files').modal('show');
    }

    function closeModalAddFiles() {
        $('div#modal-add-files').modal('hide');
    }

    function openModalMap(pStrInput) {
        $('input#geocomplete').val(pStrInput);
        $('div#modal-map').modal('show');
    }

    function closeModalMap() {
        $('div#modal-map').modal('hide');
    }

    function showLoaderMap() {
        $('i#fa-loader-map').show();
    }

    function closeLoaderMap() {
        $('div#map-details input').val('');
        $('i#fa-loader-map').hide();
    }

    function showLoaderWindow() {
        $('i#fa-loader-window').show();
    }

    function closeLoaderWindow() {
        $('i#fa-loader-window').hide();
    }

    function openHomeOwnership() {
        $('div#modal-home-ownership').modal('show');
    }

    function closeHomeOwnership() {
        $('div#modal-home-ownership').modal('hide');
    }

    function highlightLastRecord(id) {
        $('div.modal').on('shown.bs.modal', function() {
            $('table tbody tr').removeClass('selected-row');
            $("table tbody tr td:contains('"+id+"')").parent('tr').addClass('selected-row');
        });
    }

    function showAlert(msg) {
        $('span#alert-error-message').text(msg);
        $('i.fa-loader').hide();
        $('div#alert-error').fadeIn();
    }

    function hideAlert() {
        $('div#alert-error').hide();
    }

    function showSuccess(msg) {
        $('span#alert-success-message').text(msg);
        $('i.fa-loader').hide();
        $('div#alert-success').fadeIn();
    }

    function hideSuccess() {
        $('div#alert-success').hide();
    }

    // AngularJS
    APP_ASSOCIATED_MATERIALS.appAssociatedMaterials.controller('ControllerAssociatedMaterials', ['$scope', '$sce', '$filter', '$q', '$timeout', function($scope, $sce, $filter, $q, $timeout) {
        // declare and initialize $scope variables
        $scope.showProperties = false;
        $scope.updatingAddress = false;
        $scope.isWindowClaim = true;
        $scope.isOriginalOwner = true;
        $scope.isWindowClaimUpdate = true;
        $scope.isFromUpdateClaim = false;
        $scope.selectedProperty = {};
        $scope.properties = [];
        $scope.claims = [];
        $scope.status = [];
        $scope.serialNumberWindowArr = [];
        $scope.claimType = '';
        $scope.claimType2 = '';
        $scope.claimTypeUnit = '';
        $scope.claimSubject = 'Window Claim';
        $scope.propertyId = '';
        $scope.ownerStatus = 'Original Owner';
        $scope.originalOwnerStatus = '';
        $scope.transferOwnerStatus = '';
        $scope.sidingProofPurchase = '';
        $scope.claimNotes = '';
        $scope.installDate = '';
        $scope.sidingColor = '';
        $scope.serialNumberWindow = '';
        $scope.complaintType = '';
        $scope.complaintTypeSiding = '';
        $scope.uploadedAttachments = []; // all attachments uploaded to the property owner or case record
        $scope.uploadedAttachmentIdsThisSession = {}; // every time the modal to add images appears then this resets. It is to know which have just been uploaded that session and user may delete them if desired.
        $scope.isDeletingFile = false; // if deleting a file then disable other 'delete' file buttons until done to avoid double submissions
        // new property
        $scope.showNewPropertyForm = false;
        $scope.newPropertyStreet = '';
        $scope.newPropertyCity = '';
        $scope.newPropertyState = '';
        $scope.newPropertyPostalCode = '';
        $scope.newPropertyCountry = '';
        // upload file
        var maxStringSize = 6000000; // maximum string size is 6,000,000 characters
        var maxFileSize = 2000000; //4350000; // after base64 encoding, this is the max file size
        var chunkSize = 950000; // maximum javascript remoting message size is 1,000,000 characters
        var attachment;
        var positionIndex;
        var finishedUploading = false;
        var fileSize = 0;

        $scope.uploadAttachment = function(fileId, fileName) {

            var q = $q.defer();

            var attachmentBody = '';
            if(fileSize<=positionIndex+chunkSize) {
                attachmentBody = attachment.substring(positionIndex);
                finishedUploading = true;
            }else {
                attachmentBody = attachment.substring(positionIndex, positionIndex+chunkSize);
            }
            ClaimsUtilities.uploadAttachment($scope.isFromUpdateClaim, APP_ASSOCIATED_MATERIALS.lastClaimId, APP_ASSOCIATED_MATERIALS.propertyOwnerId, attachmentBody, fileName, fileId,
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                        q.reject(event.message);
                    }else if(event.status) {
                        if(result.substring(0, 3)==='00P') {
                            if(finishedUploading===true) {
                                $('i#fa-loader-file').hide();
                                $('form#form-file')[0].reset();
                                $('i#img-camera').show();
                                $scope.uploadedAttachmentIdsThisSession[result] = true;
                                q.resolve(result);
                            }else {
                                positionIndex += chunkSize;
                                $scope.uploadAttachment(result, fileName);
                            }
                        }
                    }else {
                        showAlert(event.message);
                        q.reject(event.message);
                    }
                }, {buffer: false, escape: true} // assign buffer = true for file upload, so requests are grouped together
            );

            return q.promise;
        };

        $scope.getUploadedAttachmentsAsync = function() {

            var q = $q.defer();

            ClaimsUtilities.hasAttachment($scope.isFromUpdateClaim, APP_ASSOCIATED_MATERIALS.propertyOwnerId, APP_ASSOCIATED_MATERIALS.lastClaimId,
                function(result, event) {
                    if(event.type==='exception') {
                        q.reject(event.message);
                    }else if(event.status) {
                        if(result.length && result.length > 0) {
                            q.resolve(result[0].Attachments);
                        }else {
                            q.resolve([]);
                        }
                    }else {
                        q.reject(event.message);
                    }
                },
                {buffer: false, escape: true}
            );

            return q.promise;
        };

        $scope.uploadFiles = function() {

            var q = $q.defer();

            $.map($('input#input-file').prop('files'), function(val) {
                var file = val;
                if(file!=undefined) {
                    if(file.size<=maxFileSize) {
                        var fileReader = new FileReader();
                        fileReader.onloadend = function() {
                            attachment = window.btoa(this.result); //base 64 encode the file before sending it
                            positionIndex = 0;//TODO
                            finishedUploading = false;//TODO
                            fileSize = attachment.length;
                            if(fileSize<maxStringSize) {
                                q.resolve( $scope.uploadAttachment(null, file.name) );
                            }else {
                                showAlert('Please note there is a 2.0MB per file size limit. This file is larger than 2.0MB. Please upload a file size smaller than 2.0MB.');
                                q.reject('Please note there is a 2.0MB per file size limit. This file is larger than 2.0MB. Please upload a file size smaller than 2.0MB.');
                            }
                        }
                        fileReader.onerror = function(e) {
                            showAlert('There was an error reading the file. Please try again.');
                            q.reject('There was an error reading the file. Please try again.');
                        }
                        fileReader.onabort = function(e) {
                            showAlert('There was an error reading the file. Please try again.');
                            q.reject('There was an error reading the file. Please try again.');
                        }
                        fileReader.readAsBinaryString(file); //read the body of the file
                    }else {
                        showAlert('Please note there is a 2.0MB per file size limit. This file is larger than 2.0MB. Please upload a file size smaller than 2.0MB.');
                        q.reject('Please note there is a 2.0MB per file size limit. This file is larger than 2.0MB. Please upload a file size smaller than 2.0MB.');
                    }
                }else {
                    showAlert('You must choose a file before trying to upload it');
                    q.reject('You must choose a file before trying to upload it');
                }
            });

            return q.promise;
        };

        $scope.createNewWindowClaim = function() {
            $('div#modal-warning').modal('show');
            $scope.claimType = 'Windows';
            $scope.claimType2 = 'Window';
            $scope.claimTypeUnit = 'Number';
            $scope.isWindowClaim = true;
            $scope.isFromUpdateClaim = false;
            $scope.selectedClaim = null;
            $scope.uploadedAttachments = [];
            APP_ASSOCIATED_MATERIALS.lastClaimId = null;
        };

        $scope.createNewSidingClaim = function() {
            $('div#modal-warning').modal('show');
            $scope.claimType = 'Siding';
            $scope.claimType2 = 'Siding';
            $scope.claimTypeUnit = 'Pieces';
            $scope.isWindowClaim = false;
            $scope.isFromUpdateClaim = false;
            $scope.selectedClaim = null;
            $scope.uploadedAttachments = [];
            APP_ASSOCIATED_MATERIALS.lastClaimId = null;
        };

        $scope.addSerialNumber = function() {
            if(!$scope.serialNumberWindow) {
                showAlert('You must enter a window serial number.');
                return;
            }
            $scope.serialNumberWindowArr.push($scope.serialNumberWindow);
            $scope.serialNumberWindow = '';
            $('input#serial-number-window').focus();
        };

        $scope.addProperty = function() {
            $scope.showNewPropertyForm = false;
            $scope.newPropertyStreet = '';
            $scope.newPropertyCity = '';
            $scope.newPropertyState = '';
            $scope.newPropertyPostalCode = '';
            $scope.newPropertyCountry = '';
            closeModalSelectProperty();
            openModalMap($scope.searchProperties);
        };

        $scope.saveFile = function() {

            if(!$('input#input-file').val()) {
                showAlert('You must select a file to upload.');
                return;
            }

            var defer = $q.defer();

            defer.promise
                .then( function() {

                    hideAlert();
                    $('i#fa-loader-file').show();
                    return $scope.uploadFiles();

                })
                .then( function() {

                    return $scope.getUploadedAttachmentsAsync();

                })
                .then( function( attachments ) {

                    $scope.uploadedAttachments = attachments;

                }).catch( function( err ) {

                    console.error( err );
                    showAlert( err );

                });

            defer.resolve();

        };

        $scope.deleteFile = function( attachmentId ) {

            hideAlert();
            $scope.isDeletingFile = true;

            var defer = $q.defer();

            defer.promise
                .then( function() {

                    var q = $q.defer();

                    ClaimsUtilities.deleteAttachment( attachmentId,
                        function(result, event) {

                            if(event.type==='exception') {
                                q.reject(event.message);
                            }else if(event.status) {
                                q.resolve();
                            }else{
                                q.reject(event.message);
                            }
                        },
                        {buffer: false, escape: true}
                    );

                    return q.promise;

                }).catch( function( err ) {

                    console.error( err );
                    showAlert( err );

                })
                .then( function() {

                    return $scope.getUploadedAttachmentsAsync();

                })
                .then( function( attachments ) {

                    $scope.uploadedAttachments = attachments;
                    $scope.isDeletingFile = false;

                });

            defer.resolve();

        };

        $scope.resetForms = function() {
            $('input#geocomplete').val('');
            $('input[name="opt-radio-status"]').first().trigger('click');
            $('div#modal-window-claim input, div#modal-window-claim textarea').val('');
            $('form#form-file')[0].reset();
            $scope.serialNumberWindow = '';
            $scope.complaintType = '';
            $scope.complaintTypeSiding = '';
            $scope.areaConcern = [];
            $scope.claimNotes = '';
            $scope.serialNumberWindowArr = [];
        };

        $scope.saveClaim = function() {
            $scope.isFromUpdateClaim = false;
            if($scope.isWindowClaim) {
                $scope.claimSubject = 'New Window Claim';
            }else {
                $scope.claimSubject = 'New Siding Claim';
                $scope.serialNumberWindow = '';
            }
            // validate form
            var $serialNumberWindow = $('input#serial-number-window');
            // validate window serial number
            if($scope.isWindowClaim && ((!$scope.serialNumberWindowArr.length && !$scope.serialNumberWindow) || !$scope.numberAffected || !$('select#area-concern option:selected').text())) {
                $serialNumberWindow.focus();
                showAlert('You must complete the form.');
                return;
            }else if(!$scope.isWindowClaim && (!$scope.numberAffected || !$scope.installDate)) {
                $('input#number-affected').focus();
                showAlert('You must complete the form.');
                return;
            }else {
                if(!$scope.serialNumberWindowArr.length) {
                    if($scope.serialNumberWindow) {
                        $scope.serialNumberWindowArr.push($scope.serialNumberWindow);
                    }
                }
                if(!$scope.serialNumberWindowArr.length) {
                    $scope.serialNumberWindowArr = $scope.serialNumberWindowArr.push('');
                    if($scope.serialNumberWindowArr===1) {
                        $scope.serialNumberWindowArr = '';
                    }
                }
                if($scope.areaConcern) {
                    $scope.areaConcern = $scope.areaConcern.join(';');
                }else{
                    $scope.areaConcern = '';
                }
                showLoaderWindow();
                ClaimsUtilities.saveClaim(APP_ASSOCIATED_MATERIALS.propertyOwnerId, APP_ASSOCIATED_MATERIALS.accountId, APP_ASSOCIATED_MATERIALS.contactId, $scope.propertyId, $scope.claimSubject, $scope.serialNumberWindowArr.toString(), $scope.claimNotes, $scope.ownerStatus, $scope.originalOwnerStatus, $scope.transferOwnerStatus + ' - ' + $scope.sidingProofPurchase, $scope.numberAffected, $scope.complaintType, $scope.complaintTypeSiding, $scope.areaConcern, $scope.installDate, $scope.brand, $scope.productType, $scope.sidingColor,
                    function(result, event) {
                        if(event.type==='exception') {
                            showAlert(event.message);
                        }else if(event.status) {
                            APP_ASSOCIATED_MATERIALS.lastClaimId = result;
                            // file upload
                            positionIndex = 0;
                            finishedUploading = false;
                            closeWindowClaimModal();
                            closeLoaderWindow();
                            $scope.getClaims();
                            $scope.resetForms();
                            highlightLastRecord(result);
                            openModalSelectClaim();
                            hideAlert();
                            showSuccess('Claim saved!');
                        }else{
                            showAlert(event.message);
                        }
                    },
                    {buffer: false, escape: true}
                );
            }
        };

        $scope.saveProperty = function() {

            // note, version 1.7.0 of jquery.geocomplete.min.js
            // hardcodes the address components it parses from google (poor design)
            // and so we've modified the file to include 'sublocality_level_1' type.
            // keep this in mind if you decide to upgrade or alter the plugin.

            var $formatted_address = $('input#formatted_address').val(); // postal address e.g. "3165 TN-100, Centerville, TN 37033, USA"
            var $streetNumber = $('input#street_number').val();          // street number e.g. "3165"
            var $locality = $('input#locality').val();                   // city e.g. "Centerville" (if blank then use other city field)
            var $sublocality1 = $('input#sublocality_level_1').val();    // city, sometimes when 'locality' not found
            var $adminAreaLevel3 = $('input#administrative_area_level_3').val(); // city, sometimes when 'locality' not found
            var $adminAreaLevel1 = $('input#administrative_area_level_1').val();   // state e.g. "TN"
            var $postalCode = $('input#postal_code').val();              // postal code e.g. "37033"
            var $country = $('input#country').val();                     // country e.g. "United States"

            var defer = $q.defer();

            defer.promise
                .then( function() {

                    $scope.newPropertyStreet = $formatted_address;
                    $scope.newPropertyCity = ( $locality || $sublocality1 || $adminAreaLevel3 );
                    $scope.newPropertyState = $adminAreaLevel1;
                    $scope.newPropertyPostalCode = $postalCode;
                    $scope.newPropertyCountry = $country;

                    // need to go async to get out of current $apply cycle
                    // so scope changes take effect and form validity recalculated
                    // https://stackoverflow.com/questions/25184241/angularjs-force-validation-or-wait-for-scope-myform-valid-to-refresh
                    return $timeout( function() {
                        $scope.showNewPropertyForm = $scope.newPropertyForm.$invalid;
                    });

                })
                .then( function() {

                    // validation
                    if($scope.newPropertyForm.$invalid) {
                        return;
                    }

                    showLoaderMap();

                    ClaimsUtilities.saveProperty(window.APP_ASSOCIATED_MATERIALS.propertyOwnerId, $scope.newPropertyStreet, $scope.newPropertyCity, $scope.newPropertyState, $scope.newPropertyCountry, $scope.newPropertyPostalCode,
                        function(result, event) {
                            if(event.type==='exception') {
                                showAlert(event.message);
                            }else if(event.status) {
                                closeModalMap();
                                openModalSelectProperty();
                                $('input#geocomplete').val('');
                                // now that the new property record has been inserted, refresh the your properties table
                                $scope.getProperties(window.APP_ASSOCIATED_MATERIALS.propertyOwnerId);
                                $scope.$apply();
                                closeLoaderMap();
                                highlightLastRecord(result);
                                hideAlert();
                            }else {
                                showAlert(event.message);
                            }
                        },
                        {buffer: false, escape: true}
                    );

                });

            defer.resolve();

        };

        $scope.getOriginalOwner = function() {
            $scope.isOriginalOwner = true;
            $scope.ownerStatus = 'Original Owner';
            $scope.transferOwnerStatus = '';
        };

        $scope.getTransferOwner = function() {
            $scope.isOriginalOwner = false;
            $scope.ownerStatus = 'Second Owner';
            $scope.originalOwnerStatus = '';
            $scope.numberAffected = '';
        };

        $scope.saveHomeOwner = function() {
            if((!$scope.originalOwnerStatus && !$scope.transferOwnerStatus) || !$scope.sidingProofPurchase) {
                showAlert('You must complete the form.');
                $('i#img-camera').show();
                return;
            }
            hideAlert();
            closeHomeOwnership();
            openModalAddFiles();
        };

        $scope.getProperties = function() {
            $('input#search-properties').val($('input#geocomplete').val()),
            ClaimsUtilities.getProperties(window.APP_ASSOCIATED_MATERIALS.propertyOwnerId,
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                    }else if(event.status) {
                        $scope.properties = result;
                        $scope.$apply();
                        hideAlert();
                    }else {
                        showAlert(event.message);
                    }
                },
                {buffer: false, escape: true}
            );
        };
        $scope.getProperties();

        $scope.getClaims = function() {
            $('input#search-properties').val($('input#geocomplete').val());
            ClaimsUtilities.getClaims(
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                    }else if(event.status) {
                        $scope.claims = result;
                        $scope.$apply();
                        hideAlert();
                    }else {
                        showAlert(event.message);
                    }
                },
                {buffer: false, escape: true}
            );
        };
        $scope.getClaims();

        $scope.selectProperty = function(selProp) {
            $scope.propertyId = selProp.Id;
            $scope.selectedProperty = selProp;
            closeModalSelectProperty();
            openModalConfirmProperty();
        };

        $scope.selectClaim = function(selClaim) {

            $scope.uploadedAttachments = [];

            var defer = $q.defer();

            defer.promise
                .then( function() {

                    $scope.isFromUpdateClaim = true;
                    $scope.selectedClaim = selClaim;
                    APP_ASSOCIATED_MATERIALS.lastClaimId = $scope.selectedClaim.Id;
                    highlightLastRecord($scope.selectedClaim.Id);
                    if($scope.selectedClaim.Subject) {
                        if($scope.selectedClaim.Subject.match(/window/ig)) {
                            $scope.isWindowClaimUpdate = true;
                        }else {
                            $scope.isWindowClaimUpdate = false;
                        }
                    }
                    if($scope.selectedClaim.Serial_Number__c) {
                        $scope.isWindowClaim = true;
                    }else {
                        $scope.isWindowClaim = false;
                    }

                })
                .then( function() {

                    return $scope.getUploadedAttachmentsAsync();

                })
                .then( function( attachments ) {

                    $scope.uploadedAttachments = attachments;
                    closeModalSelectClaim();

                })
                .catch( function( err ) {

                    console.error( err );
                    showAlert( err );

                });

            defer.resolve();

        };

        $scope.confirmProperty = function() {
            closeModalConfirmProperty();
            openHomeOwnership();
            // delete any staged attachments for earlier abandoned claims
            ClaimsUtilities.deleteAttachments(window.APP_ASSOCIATED_MATERIALS.propertyOwnerId,
                function(result, event) {
                    if ( !event.status ) {
                        console.error( event );
                    }
                }
            );
        };

        $scope.myProperties = function() {
            closeModalMap();
            closeModalConfirmProperty();
            openModalSelectProperty();
        };

        $scope.myClaims = function() {
            $scope.searchClaims = '';
            closeModalUpdateClaim();
            openModalSelectClaim();
        };

        $scope.updateClaim = function() {
            var $formatted_address = $('input#formatted_address').val();
            var $street_number = $('input#street_number').val();
            var $locality = $('input#locality').val();
            var $city = $('input#administrative_area_level_1').val();
            var $country = $('input#country').val();
            var $postal_code = $('input#postal_code').val();
            var $winSerNum = $('input#claim-serial-update');
            // validation
            if($scope.isWindowClaim) {
                if(!$winSerNum.val() || !$('select#area-concern-update option:selected').text() || !$('input#claim-address-update').val() || !$('input#number-affected-update').val()) {
                    showAlert('You must complete the form.');
                    $winSerNum.focus();
                    return;
                }
            }else {
                if(!$('input#claim-address-update').val() || !$('input#number-affected-update').val()) {
                    showAlert('You must complete the form.');
                    $('input#claim-address-update').focus();
                    return;
                }
            }
            var $windowAreaConcern = $.map($('select#area-concern-update option:selected'), function(el, i) {
                return $(el).text();
            }).join(';');
            $('i#fa-loader-update').show();
            // fix for undefined
            if(!$scope.selectedClaim.Serial_Number__c) {
                $scope.selectedClaim.Serial_Number__c = '';
            }
            ClaimsUtilities.updateClaim($scope.selectedClaim.Id, $scope.selectedClaim.Property__r.Id, ($scope.selectedClaim.Notes__c || ''), $scope.selectedClaim.Priority, $scope.selectedClaim.Serial_Number__c, $scope.selectedClaim.Status, $scope.selectedClaim.Subject, $scope.updatingAddress, $formatted_address, $locality, $city, $country, $postal_code, parseInt($('input#number-affected-update').val()), $('select#complaint-type-update option:selected').text(), $('select#complaint-type-siding-update option:selected').text(), $windowAreaConcern, $('input#install-date-update').val(), $('select#brand-update option:selected').text(), $('select#product-type-update option:selected').text(), $('input#siding-color-update').val(),
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                    }else if(event.status) {
                        APP_ASSOCIATED_MATERIALS.lastClaimId = $scope.selectedClaim.Id;
                        $scope.serialNumberWindowArr = [];
                        $scope.uploadFiles();
                        $scope.getClaims();
                        $scope.getProperties();
                        $('i#fa-loader-update').hide();
                        closeModalUpdateClaim();
                        openModalSelectClaim();
                        highlightLastRecord(result);
                        hideAlert();
                    }else {
                        showAlert(event.message);
                    }
                },
                {buffer: false, escape: true}
            );
        };

        $scope.getWindowComplaintTypes = function() {
            ClaimsUtilities.getWindowComplaintTypes(
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                    }else if(event.status) {
                        $scope.status = result;
                        hideAlert();
                    }else {
                        showAlert(event.message);
                    }
                },
                {buffer: false, escape: true}
            );
        };
        $scope.getWindowComplaintTypes();

        $scope.getSidingComplaintTypes = function() {
            ClaimsUtilities.getSidingComplaintTypes(
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                    }else if(event.status) {
                        $scope.statusSiding = result;
                        hideAlert();
                    }else {
                        showAlert(event.message);
                    }
                },
                {buffer: false, escape: true}
            );
        };
        $scope.getSidingComplaintTypes();

        $scope.getStatusOptionsAreaConcern = function() {
            ClaimsUtilities.getComplaintTypesAreaConcern(
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                    }else if(event.status) {
                        $scope.statusAreaConcern = result;
                        hideAlert();
                    }else {
                        showAlert(event.message);
                    }
                },
                {buffer: false, escape: true}
            );
        };
        $scope.getStatusOptionsAreaConcern();

        $scope.getOptionsBrand = function() {
            ClaimsUtilities.getOptionsBrand(
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                    }else if(event.status) {
                        $scope.statusBrand = result;
                        hideAlert();
                    }else {
                        showAlert(event.message);
                    }
                },
                {buffer: false, escape: true}
            );
        };
        $scope.getOptionsBrand();

        $scope.getOptionsProductType = function() {
            ClaimsUtilities.getOptionsProductType(
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                    }else if(event.status) {
                        $scope.statusProductType = result;
                        hideAlert();
                    }else {
                        showAlert(event.message);
                    }
                },
                {buffer: false, escape: true}
            );
        };
        $scope.getOptionsProductType();

        $scope.closeSaveFileModal = function() {
            ClaimsUtilities.hasAttachment($scope.isFromUpdateClaim, APP_ASSOCIATED_MATERIALS.propertyOwnerId, APP_ASSOCIATED_MATERIALS.lastClaimId,
                function(result, event) {
                    if(event.type==='exception') {
                        showAlert(event.message);
                    }else if(event.status) {
                        // validate the Contact has attachment
                        if(result[0].Attachments) {
                            hideAlert();
                            closeModalAddFiles();
                            if($scope.isFromUpdateClaim) {
                                openModalUpdateClaim();
                            }else {
                                openWindowClaimModal();
                            }
                        }else {
                            showAlert('You must select a file to upload.');
                        }
                    }else {
                        showAlert(event.message);
                    }
                },
                {buffer: false, escape: true}
            );
        };

        $scope.continueClaim = function() {
            $scope.isFromUpdateClaim = false;
            $('div#modal-warning').modal('hide');
            $('div#modal-select-property').modal('show');
        };

        $('i#img-camera-update').on('click', function() {
            // Every time the modal to add images appears then reset this map.
            // It is to know which attachments have just been uploaded this session and user may delete them if desired.
            $scope.uploadedAttachmentIdsThisSession = {};
            $scope.isFromUpdateClaim = true;
            $scope.$apply();
            closeModalUpdateClaim();
            openModalAddFiles();
        });
        // end AngularJS
    }]);

    // Filter for ng-repeat that given an array of attachments then filters out just those
    // that have been recently uploaded. Relies on $scope being passed via filter expression so that
    // this function can use $scope.uploadedAttachmentIdsThisSession.
    APP_ASSOCIATED_MATERIALS.appAssociatedMaterials.filter('newlyUploadedAttachments', function() {
        return function( items, $scope ) {
            var filtered = [];
            angular.forEach( items, function( item ) {
                if ( $scope.uploadedAttachmentIdsThisSession[item.Id] === true ) {
                    filtered.push( item );
                }
            });
            return filtered;
        }
    });

    // jQuery
    $('div#modal-window-claim').on('shown.bs.modal', function() {
        if($('input#serial-number-window').is(':visible')) {
            $('input#serial-number-window').focus();
        }else {
            $('input#number-affected').focus();
        }
        closeModalAddFiles(); // this was not working where intended - line 670
    });

    $('div#modal-map').on('shown.bs.modal', function() {
        $('input#geocomplete').show().focus();
        initGeocomplete();
    });

    $('div#modal-update-claim').on('shown.bs.modal', function() {
        $('i#img-camera-update').show();
        $('input#claim-serial-update').focus();
        initGeocompleteUpdateClaim();
        // fix for data-binding select option multiple
        var tempArr = angular.element($("body#ControllerAssociatedMaterials")).scope().selectedClaim.Window_Area_of_Concern__c.toString().split(';');
        for(var i=0; i<tempArr.length; i++) {
            $('select#area-concern-update option:contains('+tempArr[i]+')').prop('selected', true);
        }
    });

    $('button#close-alert-error').on('click', function() {
        $('div#alert-error').fadeOut();
    });

    $('button#close-alert-success').on('click', function() {
        $('div#alert-success').fadeOut();
    });

    $(document).on('click', '#modal-claims tr.hover-background', function() {
        var $this = $(this);
        $this.addClass('selected-row');
        $this.siblings().removeClass('selected-row');
    });

    $('div.modal').on('hide.bs.modal', function() {
        hideAlert();
    });

    $('div#modal-add-files').on('hide.bs.modal', function(event) {
        event.stopPropagation();
        ClaimsUtilities.hasAttachment($("body#ControllerAssociatedMaterials").scope().isFromUpdateClaim, APP_ASSOCIATED_MATERIALS.propertyOwnerId, APP_ASSOCIATED_MATERIALS.lastClaimId,
            function(result, event) {
                if(event.type==='exception') {
                    showAlert(event.message);
                }else if(event.status) {
                    // validate the Contact has attachment
                    if(!result.length) {
                        showAlert('You must select a file to upload.');
                    }else if(result[0].Attachments) {
                        APP_ASSOCIATED_MATERIALS.hasAttachment = true;
                    }else {
                        APP_ASSOCIATED_MATERIALS.hasAttachment = false;
                        showAlert('You must select a file to upload.');
                    }
                }else {
                    showAlert(event.message);
                }
            },
            {buffer: false, escape: true}
        );
        // prevent modal from closing if Contact does not have attachment
        if(!APP_ASSOCIATED_MATERIALS.hasAttachment) {
            return false;
        }
    });

    $('div#modal-claims').on('shown.bs.modal', function(event) {
        hideAlert();
    });

    $('input#install-date, input#install-date-update').datepicker({
        autoclose: true,
        dateFormat: 'mm/dd/yyyy',
        endDate: '+0d'
    });

    $('a#link-find-waranty').on('click', function() {
        window.open('http://www.alside.com/media/25003/june-2016-revision-window-warranty-ip-2-.pdf', '_blank');
    });

    $('input#serial-number-window, div#home-status-init, div#original-owner-status, div#transfer-owner-status, div#proof-siding-purchase-container').tooltip();

    $(document).ready(function() {
        // validate user is logged in
        if(!$('input#propertyOwnerId').val()) {
            window.location.href = '/secur/logout.jsp';
        }
        // dynamically assign company logo
        // alpine
        if(window.location.href.match(/alpine/)) {
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/alpine_logo.png').addClass('img-logo-branding-wide');
            window.localStorage.setItem('brand', 'alpine');
        }else if(window.localStorage.getItem('brand')==='alpine') {
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/alpine_logo.png').addClass('img-logo-branding-wide');
            window.localStorage.setItem('brand', 'alpine');
        }
        // gentek
        if(window.location.href.match(/gentek/)) {
            window.localStorage.setItem('brand', 'gentek');
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/gentek_logo.png').addClass('img-logo-branding-wide');
        }else if(window.localStorage.getItem('brand')==='gentek') {
            window.localStorage.setItem('brand', 'gentek');
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/gentek_logo.png').addClass('img-logo-branding-wide');
        }
        // revere
        if(window.location.href.match(/revere/)) {
            window.localStorage.setItem('brand', 'revere');
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/revere_logo.png').addClass('img-logo-branding').css('height', '300px');
        }else if(window.localStorage.getItem('brand')==='revere') {
            window.localStorage.setItem('brand', 'revere');
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/revere_logo.png').addClass('img-logo-branding img-logo-revere').css('height', '300px');
        }
        // alside
        if(window.location.href.match(/alside/)) {
            window.localStorage.setItem('brand', 'alside');
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/alside_logo.png').addClass('img-logo-branding-wide');
        }else if(window.localStorage.getItem('brand')==='alside') {
            window.localStorage.setItem('brand', 'alside');
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/alside_logo.png').addClass('img-logo-branding-wide');
        }
        // preservation
        if(window.location.href.match(/preservation/)) {
            window.localStorage.setItem('brand', 'preservation');
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/preservation_logo.png').addClass('img-logo-branding-wide');
        }else if(window.localStorage.getItem('brand')==='preservation') {
            window.localStorage.setItem('brand', 'preservation');
            $('img#img-logo').attr('src', APP_ASSOCIATED_MATERIALS.staticResourcePath+'/preservation_logo.png').addClass('img-logo-branding-wide');
        }
    });
}(jQuery));