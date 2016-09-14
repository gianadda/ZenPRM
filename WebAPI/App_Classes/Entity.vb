Imports Newtonsoft.Json.Linq

Public Class Entity

    Public Shared Function AddEntity(ByVal objEntity As JObject, ByVal intAddToEntityIdent As Int64, ByVal bolAllowOpenRegistration As Boolean,
                                        ByRef bolCheckNPIUniqueFailed As Boolean, ByRef intNewEntityIdent As Int64) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intEntityDelegateIdent As Int64 = 0
        Dim bolSuccess As Boolean = False
        Dim intAddASUserIdent As Int64 = 0

        Dim strNPI As String = ""

        Try

            If Not objEntity("NPI") Is Nothing Then

                strNPI = CType(objEntity("NPI"), String)

            End If

            If CheckUniqueNPI(0, strNPI) Then

                Call Int64.TryParse(objEntity("EntityDelegateIdent"), intEntityDelegateIdent)

                'if its open registration, we will assume the adding entity is the customer (since the user wont exist yet)
                If bolAllowOpenRegistration Then

                    intAddASUserIdent = intAddToEntityIdent

                Else

                    intAddASUserIdent = Helper.AddEditASUserIdent

                End If

                slParameters = New SortedList

                slParameters.Add("EntityTypeIdent", IIf(IsNothing(objEntity("EntityTypeIdent")), 0, objEntity("EntityTypeIdent")))
                slParameters.Add("NPI", IIf(IsNothing(objEntity("NPI")), "", objEntity("NPI")))
                slParameters.Add("DBA", IIf(IsNothing(objEntity("DBA")), "", objEntity("DBA")))
                slParameters.Add("OrganizationName", IIf(IsNothing(objEntity("OrganizationName")), "", objEntity("OrganizationName")))
                slParameters.Add("Prefix", IIf(IsNothing(objEntity("Prefix")), "", objEntity("Prefix")))
                slParameters.Add("FirstName", IIf(IsNothing(objEntity("FirstName")), "", objEntity("FirstName")))
                slParameters.Add("MiddleName", IIf(IsNothing(objEntity("MiddleName")), "", objEntity("MiddleName")))
                slParameters.Add("LastName", IIf(IsNothing(objEntity("LastName")), "", objEntity("LastName")))
                slParameters.Add("Suffix", IIf(IsNothing(objEntity("Suffix")), "", objEntity("Suffix")))
                slParameters.Add("Title", IIf(IsNothing(objEntity("Title")), "", objEntity("Title")))
                slParameters.Add("MedicalSchool", IIf(IsNothing(objEntity("MedicalSchool")), "", objEntity("MedicalSchool")))
                slParameters.Add("SoleProvider", IIf(IsNothing(objEntity("SoleProvider")), False, objEntity("SoleProvider")))
                slParameters.Add("AcceptingNewPatients", IIf(IsNothing(objEntity("AcceptingNewPatients")), False, objEntity("AcceptingNewPatients")))
                slParameters.Add("GenderIdent", IIf(IsNothing(objEntity("GenderIdent")), 0, objEntity("GenderIdent")))
                slParameters.Add("Role1", IIf(IsNothing(objEntity("Role1")), "", objEntity("Role1")))
                slParameters.Add("Version1", IIf(IsNothing(objEntity("Version1")), "", objEntity("Version1")))
                slParameters.Add("PCMHStatusIdent", IIf(IsNothing(objEntity("PCMHStatusIdent")), 0, objEntity("PCMHStatusIdent")))
                slParameters.Add("PrimaryAddress1", IIf(IsNothing(objEntity("PrimaryAddress1")), "", objEntity("PrimaryAddress1")))
                slParameters.Add("PrimaryAddress2", IIf(IsNothing(objEntity("PrimaryAddress2")), "", objEntity("PrimaryAddress2")))
                slParameters.Add("PrimaryAddress3", IIf(IsNothing(objEntity("PrimaryAddress3")), "", objEntity("PrimaryAddress3")))
                slParameters.Add("PrimaryCity", IIf(IsNothing(objEntity("PrimaryCity")), "", objEntity("PrimaryCity")))
                slParameters.Add("PrimaryStateIdent", IIf(IsNothing(objEntity("PrimaryStateIdent")), 0, objEntity("PrimaryStateIdent")))
                slParameters.Add("PrimaryZip", IIf(IsNothing(objEntity("PrimaryZip")), "", objEntity("PrimaryZip")))
                slParameters.Add("PrimaryCounty", IIf(IsNothing(objEntity("PrimaryCounty")), "", objEntity("PrimaryCounty")))
                slParameters.Add("PrimaryPhone", IIf(IsNothing(objEntity("PrimaryPhone")), "", objEntity("PrimaryPhone")))
                slParameters.Add("PrimaryPhoneExtension", IIf(IsNothing(objEntity("PrimaryPhoneExtension")), "", objEntity("PrimaryPhoneExtension")))
                slParameters.Add("PrimaryPhone2", IIf(IsNothing(objEntity("PrimaryPhone2")), "", objEntity("PrimaryPhone2")))
                slParameters.Add("PrimaryPhone2Extension", IIf(IsNothing(objEntity("PrimaryPhone2Extension")), "", objEntity("PrimaryPhone2Extension")))
                slParameters.Add("PrimaryFax", IIf(IsNothing(objEntity("PrimaryFax")), "", objEntity("PrimaryFax")))
                slParameters.Add("PrimaryFax2", IIf(IsNothing(objEntity("PrimaryFax2")), "", objEntity("PrimaryFax2")))
                slParameters.Add("MailingAddress1", IIf(IsNothing(objEntity("MailingAddress1")), "", objEntity("MailingAddress1")))
                slParameters.Add("MailingAddress2", IIf(IsNothing(objEntity("MailingAddress2")), "", objEntity("MailingAddress2")))
                slParameters.Add("MailingAddress3", IIf(IsNothing(objEntity("MailingAddress3")), "", objEntity("MailingAddress3")))
                slParameters.Add("MailingCity", IIf(IsNothing(objEntity("MailingCity")), "", objEntity("MailingCity")))
                slParameters.Add("MailingStateIdent", IIf(IsNothing(objEntity("MailingStateIdent")), 0, objEntity("MailingStateIdent")))
                slParameters.Add("MailingZip", IIf(IsNothing(objEntity("MailingZip")), "", objEntity("MailingZip")))
                slParameters.Add("MailingCounty", IIf(IsNothing(objEntity("MailingCounty")), "", objEntity("MailingCounty")))
                slParameters.Add("PracticeAddress1", IIf(IsNothing(objEntity("PracticeAddress1")), "", objEntity("PracticeAddress1")))
                slParameters.Add("PracticeAddress2", IIf(IsNothing(objEntity("PracticeAddress2")), "", objEntity("PracticeAddress2")))
                slParameters.Add("PracticeAddress3", IIf(IsNothing(objEntity("PracticeAddress3")), "", objEntity("PracticeAddress3")))
                slParameters.Add("PracticeCity", IIf(IsNothing(objEntity("PracticeCity")), "", objEntity("PracticeCity")))
                slParameters.Add("PracticeStateIdent", IIf(IsNothing(objEntity("PracticeStateIdent")), 0, objEntity("PracticeStateIdent")))
                slParameters.Add("PracticeZip", IIf(IsNothing(objEntity("PracticeZip")), "", objEntity("PracticeZip")))
                slParameters.Add("PracticeCounty", IIf(IsNothing(objEntity("PracticeCounty")), "", objEntity("PracticeCounty")))
                slParameters.Add("ProfilePhoto", IIf(IsNothing(objEntity("ProfilePhoto")), "", objEntity("ProfilePhoto")))
                slParameters.Add("Website", IIf(IsNothing(objEntity("Website")), "", objEntity("Website")))
                slParameters.Add("PrescriptionLicenseNumber", IIf(IsNothing(objEntity("PrescriptionLicenseNumber")), "", objEntity("PrescriptionLicenseNumber")))
                slParameters.Add("PrescriptionLicenseNumberExpirationDate", IIf(IsNothing(objEntity("PrescriptionLicenseNumberExpirationDate")), "1/1/1900", objEntity("PrescriptionLicenseNumberExpirationDate")))
                slParameters.Add("DEANumber", IIf(IsNothing(objEntity("DEANumber")), "", objEntity("DEANumber")))
                slParameters.Add("DEANumberExpirationDate", IIf(IsNothing(objEntity("DEANumberExpirationDate")), "1/1/1900", objEntity("DEANumberExpirationDate")))
                slParameters.Add("TaxIDNumber", IIf(IsNothing(objEntity("TaxIDNumber")), "", objEntity("TaxIDNumber")))
                slParameters.Add("TaxIDNumberExpirationDate", IIf(IsNothing(objEntity("TaxIDNumberExpirationDate")), "1/1/1900", objEntity("TaxIDNumberExpirationDate")))
                slParameters.Add("MedicareUPIN", IIf(IsNothing(objEntity("MedicareUPIN")), "", objEntity("MedicareUPIN")))
                slParameters.Add("CAQHID", IIf(IsNothing(objEntity("CAQHID")), "", objEntity("CAQHID")))
                slParameters.Add("MeaningfulUseIdent", IIf(IsNothing(objEntity("MeaningfulUseIdent")), 0, objEntity("MeaningfulUseIdent")))
                slParameters.Add("EIN", IIf(IsNothing(objEntity("EIN")), "", objEntity("EIN")))
                slParameters.Add("Latitude", IIf(IsNothing(objEntity("Latitude")), 0.0, objEntity("Latitude")))
                slParameters.Add("Longitude", IIf(IsNothing(objEntity("Longitude")), 0.0, objEntity("Longitude")))
                slParameters.Add("Region", IIf(IsNothing(objEntity("Region")), "", objEntity("Region")))
                slParameters.Add("BirthDate", IIf(IsNothing(objEntity("BirthDate")), "1/1/1900", objEntity("BirthDate")))
                slParameters.Add("Email", IIf(IsNothing(objEntity("ImportEmailAddress")), "", objEntity("ImportEmailAddress")))
                slParameters.Add("AddToEntityIdent", intAddToEntityIdent)
                slParameters.Add("AddASUserIdent", intAddASUserIdent)
                slParameters.Add("Active", IIf(IsNothing(objEntity("Active")), True, objEntity("Active")))
                slParameters.Add("EntityDelegateIdent", intEntityDelegateIdent)

                If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntity", slParameters, intNewEntityIdent, dsMessage) Then

                    If intNewEntityIdent > 0 Then

                        bolSuccess = True

                    End If


                End If 'uspAddEntity

            Else 'IsUniqueNPI = false

                bolCheckNPIUniqueFailed = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            AddEntity = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function AddEntityEmail(ByVal intEntityIdent As Int64, ByVal strEmailAddress As String, ByVal bolNotify As Boolean, ByVal bolVerified As Boolean, ByVal intVerifiedASUserIdent As Int64, _
                                            ByRef dsResults As DataSet) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", intEntityIdent)
            slParameters.Add("Email", strEmailAddress)
            slParameters.Add("Notify", bolNotify)
            slParameters.Add("Verified", bolVerified)
            slParameters.Add("VerifiedASUserIdent", intVerifiedASUserIdent)
            slParameters.Add("AddASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("Active", True)
            slParameters.Add("SuppressOutput", False)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityEmail", slParameters, True, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    bolSuccess = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            AddEntityEmail = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function AddEntityExternalLogin(ByVal intEntityIdent As Int64, _
                                                  ByVal strExternalSource As String, _
                                                  ByVal strExternalNameIdentifier As String, _
                                                  ByVal strExternalEmailAddress As String, _
                                                  ByVal intAddASUserIdent As Int64) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False
        Dim intIdent As Int64 = 0

        Try

            slParameters = New SortedList

            slParameters.Add("EntityIdent", intEntityIdent)
            slParameters.Add("AddASUserIdent", intAddASUserIdent)
            slParameters.Add("ExternalSource", strExternalSource)
            slParameters.Add("ExternalNameIdentifier", strExternalNameIdentifier)
            slParameters.Add("ExternalEmailAddress", strExternalEmailAddress)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityExternalLogin", slParameters, intIdent, dsMessage) Then

                If intIdent > 0 Then

                    bolSuccess = True

                End If


            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            AddEntityExternalLogin = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try


    End Function

    Public Shared Function AddEntityOtherID(ByVal intEntityIdent As Int64, ByVal strIDType As String, ByVal strIDNumber As String, ByVal intAddASUserIdent As Int64,
                                                ByRef intEntityOtherIDIdent As Int64) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList

            slParameters.Add("EntityIdent", intEntityIdent)
            slParameters.Add("IDType", strIDType)
            slParameters.Add("IDNumber", strIDNumber)
            slParameters.Add("AddASUserIdent", intAddASUserIdent)
            slParameters.Add("Active", True)

            If Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityOtherID", slParameters, intEntityOtherIDIdent, dsMessage) Then

                If intEntityOtherIDIdent > 0 Then

                    bolSuccess = True

                End If


            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            AddEntityOtherID = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try


    End Function

    Public Shared Function BulkAddImportEntity(ByRef objResources As JArray) As Boolean

        Dim bolNPICheckUnique As Boolean = False
        Dim bolAccessDenied As Boolean = False
        Dim intEntityIdent As Int64 = 0
        Dim bolSuccess As Boolean = False
        Dim dsEntity As DataSet = Nothing

        Try

            Call LogBulkAddImportEntity(objResources.ToString)

            'Loop through the records, check if they are already in network, then add or update
            'Return to the client which records were added, edited, or ignored
            For Each objResource As JObject In objResources.Children()

                bolSuccess = False
                bolNPICheckUnique = False
                bolAccessDenied = False
                intEntityIdent = 0

                Call Int64.TryParse(objResource("Ident"), intEntityIdent)

                If intEntityIdent > 0 Then

                    dsEntity = New DataSet
                    bolSuccess = EditEntityByIdent(objResource, dsEntity, bolAccessDenied)

                Else

                    bolSuccess = AddEntity(objResource, Helper.ASUserIdent, False, bolNPICheckUnique, intEntityIdent)

                End If

                objResource("ImportStatus") = bolSuccess

            Next

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            BulkAddImportEntity = True

            Helper.CleanUp(dsEntity)

        End Try

    End Function

    Public Shared Function BulkAddVerifyEntity(ByVal bolPrivateOnly As Boolean, ByRef objResources As JArray) As Boolean

        Dim intEntityIdent As Int64 = 0
        Dim intEntitiesMatched As Int64 = 0

        Dim dsEntity As DataSet = Nothing
        Dim searchObject As EntitySearch = Nothing
        Dim searchfilter As EntitySearchFilter = Nothing
        Dim objResult As JObject = Nothing

        Dim strNPI As String = ""
        Dim strLastName As String = ""
        Dim strFirstName As String = ""
        Dim strOrganizationName As String = ""

        Try

            'Loop through the records, check if they are already in network, then add or update
            'Return to the client which records were added, edited, or ignored
            For Each objResource As JObject In objResources.Children()

                intEntityIdent = 0
                intEntitiesMatched = 0
                searchObject = New EntitySearch

                strNPI = (IIf(IsNothing(objResource("NPI")), "", objResource("NPI"))).ToString.Trim
                strLastName = (IIf(IsNothing(objResource("LastName")), "", objResource("LastName"))).ToString.Trim
                strFirstName = (IIf(IsNothing(objResource("FirstName")), "", objResource("FirstName"))).ToString.Trim
                strOrganizationName = (IIf(IsNothing(objResource("OrganizationName")), "", objResource("OrganizationName"))).ToString.Trim

                If bolPrivateOnly Then

                    If strFirstName.Length > 0 And strLastName.Length > 0 Then

                        objResource("EntityTypeIdent") = Helper.enmEntityType.PrivateContact
                        searchObject.keyword = strFirstName & " " & strLastName

                    Else

                        objResource("EntityTypeIdent") = Helper.enmEntityType.Other
                        searchObject.keyword = strOrganizationName

                    End If

                Else ' Allow Public Resources - not used in initial rollout

                    If strFirstName.Length > 0 And _
                        strLastName.Length > 0 And _
                        strNPI.Length > 0 Then

                        objResource("EntityTypeIdent") = Helper.enmEntityType.Provider
                        searchObject.keyword = strFirstName & " " & strLastName

                    ElseIf strOrganizationName.Length > 0 And _
                        strNPI.Length > 0 Then

                        objResource("EntityTypeIdent") = Helper.enmEntityType.Organization
                        searchObject.keyword = strOrganizationName

                    ElseIf strFirstName.Length > 0 And _
                        strLastName.Length > 0 Then

                        objResource("EntityTypeIdent") = Helper.enmEntityType.PrivateContact
                        searchObject.keyword = strFirstName & " " & strLastName

                    Else

                        objResource("EntityTypeIdent") = Helper.enmEntityType.Other
                        searchObject.keyword = strOrganizationName

                    End If

                End If

                'Convert string values to Idents
                If Not objResource("Gender") Is Nothing AndAlso _
                    objResource("Gender").ToString.Trim.Length > 0 Then

                    objResource("GenderIdent") = LookupTables.GetGenderIdentByName(objResource("Gender").ToString.Trim)

                End If

                If Not objResource("PrimaryState") Is Nothing AndAlso _
                    objResource("PrimaryState").ToString.Trim.Length > 0 Then

                    objResource("PrimaryStateIdent") = LookupTables.GetStatesIdentByName(objResource("PrimaryState").ToString.Trim)

                End If

                If Not objResource("MailingState") Is Nothing AndAlso _
                    objResource("MailingState").ToString.Trim.Length > 0 Then

                    objResource("MailingStateIdent") = LookupTables.GetStatesIdentByName(objResource("MailingState").ToString.Trim)

                End If

                If Not objResource("PracticeState") Is Nothing AndAlso _
                    objResource("PracticeState").ToString.Trim.Length > 0 Then

                    objResource("PracticeStateIdent") = LookupTables.GetStatesIdentByName(objResource("PracticeState").ToString.Trim)

                End If

                searchfilter = New EntitySearchFilter
                searchfilter.entityProjectRequirementIdent = 0
                searchfilter.entitySearchFilterTypeIdent = Helper.enmEntitySearchFilterType.EntityType
                searchfilter.entitySearchOperatorIdent = 0
                searchfilter.referenceIdent = 0
                searchfilter.searchValue = objResource("EntityTypeIdent")

                searchObject.resultsShown = 10 ' set an arbitrary limit
                searchObject.searchGlobal = False
                searchObject.filters.Add(searchfilter)

                dsEntity = New DataSet

                Call SearchEntity(searchObject, dsEntity)

                If Not dsEntity Is Nothing Then

                    If dsEntity.Tables.Count >= 1 Then

                        intEntitiesMatched = dsEntity.Tables(0).Rows(0)("TotalResults")

                    End If

                End If 'If Not dsEntity Is Nothing

                If intEntitiesMatched = 1 Then

                    objResource("Ident") = CType(dsEntity.Tables(1).Rows(0)("Ident"), Int64)
                    objResource("ImportAction") = "Update"
                    objResource("selected") = True

                    objResource("MatchCount") = intEntitiesMatched
                    objResource("MatchedEntities") = New JArray

                    objResult = New JObject
                    objResult("Ident") = CType(dsEntity.Tables(1).Rows(0)("Ident"), Int64)
                    objResult("DisplayName") = CType(dsEntity.Tables(1).Rows(0)("DisplayName"), String)
                    objResult("ProfilePhoto") = CType(dsEntity.Tables(1).Rows(0)("ProfilePhoto"), String)

                    CType(objResource("MatchedEntities"), JArray).Add(objResult)

                ElseIf intEntitiesMatched = 0 Then

                    objResource("Ident") = 0
                    objResource("ImportAction") = "Add"
                    objResource("selected") = True

                    objResource("MatchCount") = intEntitiesMatched
                    objResource("MatchedEntities") = New JArray

                Else

                    objResource("Ident") = 0
                    objResource("ImportAction") = "Exception"
                    objResource("selected") = False
                    objResource("MatchCount") = intEntitiesMatched
                    objResource("MatchedEntities") = New JObject
                    
                    objResource("MatchCount") = intEntitiesMatched
                    objResource("MatchedEntities") = New JArray

                    For Each drRow As DataRow In dsEntity.Tables(1).Rows

                        objResult = New JObject
                        objResult("Ident") = CType(drRow("Ident"), Int64)
                        objResult("DisplayName") = CType(drRow("DisplayName"), String)
                        objResult("ProfilePhoto") = CType(drRow("ProfilePhoto"), String)

                        CType(objResource("MatchedEntities"), JArray).Add(objResult)

                    Next

                End If 'If intEntitiesMatched = 1

            Next 'For Each objResource As JObject In objResources.Children()

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            BulkAddVerifyEntity = True

            Helper.CleanUp(dsEntity)
            Helper.CleanUp(searchObject)
            Helper.CleanUp(objResult)

        End Try

    End Function

    Public Shared Function CheckUniqueEntityEmail(ByVal strEmailAddress As String, ByRef entityIdent As Int64, ByRef entityFullName As String) As Boolean

        Dim dsResults As DataSet = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim slParameters As SortedList = Nothing
        Dim bolIsUnique As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("Email", strEmailAddress)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspCheckEntityEmailUnique", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso _
                    dsResults.Tables.Count > 0 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    bolIsUnique = False
                    entityIdent = CType(dsResults.Tables(0).Rows(0)("Ident"), Int64)
                    entityFullName = CType(dsResults.Tables(0).Rows(0)("FullName"), String)

                Else

                    bolIsUnique = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            CheckUniqueEntityEmail = bolIsUnique

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Public Shared Function CheckUniqueNPI(ByVal intIdent As Int64, ByVal strNPI As String) As Boolean

        Dim bolUnique As Boolean = False
        Dim dsMessage As DataSet = Nothing
        Dim slParameters As SortedList = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("Ident", intIdent)
            slParameters.Add("NPI", strNPI)

            Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspCheckEntityNPIUnique", slParameters, bolUnique, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            CheckUniqueNPI = bolUnique

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Public Shared Function EditEntityByIdent(ByVal objEntity As JObject, ByRef dsEntity As DataSet, ByRef bolAccessDenied As Boolean) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim intIdent As Int64 = 0
        Dim strProfilePhotoLink As String = ""
        Dim strContentToUpload As String = ""
        Dim bolSuccess As Boolean = False

        Try

            Call Int64.TryParse(objEntity("Ident"), intIdent)

            If intIdent > 0 AndAlso _
                Login.CheckUserAccessToEntityProfile(intIdent) Then

                'make sure we have the profile photo
                If Not objEntity("ProfilePhoto") Is Nothing Then

                    strContentToUpload = objEntity("ProfilePhoto").ToString()

                    'if the string contains base64, it means we're uploading a new image
                    If strContentToUpload.Contains("base64") Then

                        strProfilePhotoLink = UploadEntityProfilePhoto(strContentToUpload, intIdent)

                    Else

                        'if were not uploading a new image, just save the original one
                        strProfilePhotoLink = strContentToUpload

                    End If

                End If 'If Not objEntity("ProfilePhoto") 

                slParameters = New SortedList
                slParameters.Add("Ident", intIdent)
                slParameters.Add("NPI", IIf(IsNothing(objEntity("NPI")), "", objEntity("NPI")))
                slParameters.Add("DBA", IIf(IsNothing(objEntity("DBA")), "", objEntity("DBA")))
                slParameters.Add("OrganizationName", IIf(IsNothing(objEntity("OrganizationName")), "", objEntity("OrganizationName")))
                slParameters.Add("Prefix", IIf(IsNothing(objEntity("Prefix")), "", objEntity("Prefix")))
                slParameters.Add("FirstName", IIf(IsNothing(objEntity("FirstName")), "", objEntity("FirstName")))
                slParameters.Add("MiddleName", IIf(IsNothing(objEntity("MiddleName")), "", objEntity("MiddleName")))
                slParameters.Add("LastName", IIf(IsNothing(objEntity("LastName")), "", objEntity("LastName")))
                slParameters.Add("Suffix", IIf(IsNothing(objEntity("Suffix")), "", objEntity("Suffix")))
                slParameters.Add("Title", IIf(IsNothing(objEntity("Title")), "", objEntity("Title")))
                slParameters.Add("MedicalSchool", IIf(IsNothing(objEntity("MedicalSchool")), "", objEntity("MedicalSchool")))
                slParameters.Add("SoleProvider", IIf(IsNothing(objEntity("SoleProvider")), False, objEntity("SoleProvider")))
                slParameters.Add("AcceptingNewPatients", IIf(IsNothing(objEntity("AcceptingNewPatients")), False, objEntity("AcceptingNewPatients")))
                slParameters.Add("GenderIdent", IIf(IsNothing(objEntity("GenderIdent")), 0, objEntity("GenderIdent")))
                slParameters.Add("Role1", IIf(IsNothing(objEntity("Role1")), "", objEntity("Role1")))
                slParameters.Add("Version1", IIf(IsNothing(objEntity("Version1")), "", objEntity("Version1")))
                slParameters.Add("PCMHStatusIdent", IIf(IsNothing(objEntity("PCMHStatusIdent")), 0, objEntity("PCMHStatusIdent")))
                slParameters.Add("PrimaryAddress1", IIf(IsNothing(objEntity("PrimaryAddress1")), "", objEntity("PrimaryAddress1")))
                slParameters.Add("PrimaryAddress2", IIf(IsNothing(objEntity("PrimaryAddress2")), "", objEntity("PrimaryAddress2")))
                slParameters.Add("PrimaryAddress3", IIf(IsNothing(objEntity("PrimaryAddress3")), "", objEntity("PrimaryAddress3")))
                slParameters.Add("PrimaryCity", IIf(IsNothing(objEntity("PrimaryCity")), "", objEntity("PrimaryCity")))
                slParameters.Add("PrimaryStateIdent", IIf(IsNothing(objEntity("PrimaryStateIdent")), 0, objEntity("PrimaryStateIdent")))
                slParameters.Add("PrimaryZip", IIf(IsNothing(objEntity("PrimaryZip")), "", objEntity("PrimaryZip")))
                slParameters.Add("PrimaryCounty", IIf(IsNothing(objEntity("PrimaryCounty")), "", objEntity("PrimaryCounty")))
                slParameters.Add("PrimaryPhone", IIf(IsNothing(objEntity("PrimaryPhone")), "", objEntity("PrimaryPhone")))
                slParameters.Add("PrimaryPhoneExtension", IIf(IsNothing(objEntity("PrimaryPhoneExtension")), "", objEntity("PrimaryPhoneExtension")))
                slParameters.Add("PrimaryPhone2", IIf(IsNothing(objEntity("PrimaryPhone2")), "", objEntity("PrimaryPhone2")))
                slParameters.Add("PrimaryPhone2Extension", IIf(IsNothing(objEntity("PrimaryPhone2Extension")), "", objEntity("PrimaryPhone2Extension")))
                slParameters.Add("PrimaryFax", IIf(IsNothing(objEntity("PrimaryFax")), "", objEntity("PrimaryFax")))
                slParameters.Add("PrimaryFax2", IIf(IsNothing(objEntity("PrimaryFax2")), "", objEntity("PrimaryFax2")))
                slParameters.Add("MailingAddress1", IIf(IsNothing(objEntity("MailingAddress1")), "", objEntity("MailingAddress1")))
                slParameters.Add("MailingAddress2", IIf(IsNothing(objEntity("MailingAddress2")), "", objEntity("MailingAddress2")))
                slParameters.Add("MailingAddress3", IIf(IsNothing(objEntity("MailingAddress3")), "", objEntity("MailingAddress3")))
                slParameters.Add("MailingCity", IIf(IsNothing(objEntity("MailingCity")), "", objEntity("MailingCity")))
                slParameters.Add("MailingStateIdent", IIf(IsNothing(objEntity("MailingStateIdent")), 0, objEntity("MailingStateIdent")))
                slParameters.Add("MailingZip", IIf(IsNothing(objEntity("MailingZip")), "", objEntity("MailingZip")))
                slParameters.Add("MailingCounty", IIf(IsNothing(objEntity("MailingCounty")), "", objEntity("MailingCounty")))
                slParameters.Add("PracticeAddress1", IIf(IsNothing(objEntity("PracticeAddress1")), "", objEntity("PracticeAddress1")))
                slParameters.Add("PracticeAddress2", IIf(IsNothing(objEntity("PracticeAddress2")), "", objEntity("PracticeAddress2")))
                slParameters.Add("PracticeAddress3", IIf(IsNothing(objEntity("PracticeAddress3")), "", objEntity("PracticeAddress3")))
                slParameters.Add("PracticeCity", IIf(IsNothing(objEntity("PracticeCity")), "", objEntity("PracticeCity")))
                slParameters.Add("PracticeStateIdent", IIf(IsNothing(objEntity("PracticeStateIdent")), 0, objEntity("PracticeStateIdent")))
                slParameters.Add("PracticeZip", IIf(IsNothing(objEntity("PracticeZip")), "", objEntity("PracticeZip")))
                slParameters.Add("PracticeCounty", IIf(IsNothing(objEntity("PracticeCounty")), "", objEntity("PracticeCounty")))
                slParameters.Add("ProfilePhoto", strProfilePhotoLink)
                slParameters.Add("Website", IIf(IsNothing(objEntity("Website")), "", objEntity("Website")))
                slParameters.Add("PrescriptionLicenseNumber", IIf(IsNothing(objEntity("PrescriptionLicenseNumber")), "", objEntity("PrescriptionLicenseNumber")))
                slParameters.Add("PrescriptionLicenseNumberExpirationDate", IIf(IsNothing(objEntity("PrescriptionLicenseNumberExpirationDate")), "1/1/1900", objEntity("PrescriptionLicenseNumberExpirationDate")))
                slParameters.Add("DEANumber", IIf(IsNothing(objEntity("DEANumber")), "", objEntity("DEANumber")))
                slParameters.Add("DEANumberExpirationDate", IIf(IsNothing(objEntity("DEANumberExpirationDate")), "1/1/1900", objEntity("DEANumberExpirationDate")))
                slParameters.Add("TaxIDNumber", IIf(IsNothing(objEntity("TaxIDNumber")), "", objEntity("TaxIDNumber")))
                slParameters.Add("TaxIDNumberExpirationDate", IIf(IsNothing(objEntity("TaxIDNumberExpirationDate")), "1/1/1900", objEntity("TaxIDNumberExpirationDate")))
                slParameters.Add("MedicareUPIN", IIf(IsNothing(objEntity("MedicareUPIN")), "", objEntity("MedicareUPIN")))
                slParameters.Add("CAQHID", IIf(IsNothing(objEntity("CAQHID")), "", objEntity("CAQHID")))
                slParameters.Add("MeaningfulUseIdent", IIf(IsNothing(objEntity("MeaningfulUseIdent")), 0, objEntity("MeaningfulUseIdent")))
                slParameters.Add("EIN", IIf(IsNothing(objEntity("EIN")), "", objEntity("EIN")))
                slParameters.Add("Latitude", IIf(IsNothing(objEntity("Latitude")), 0.0, objEntity("Latitude")))
                slParameters.Add("Longitude", IIf(IsNothing(objEntity("Longitude")), 0.0, objEntity("Longitude")))
                slParameters.Add("Region", IIf(IsNothing(objEntity("Region")), "", objEntity("Region")))
                slParameters.Add("Email", IIf(IsNothing(objEntity("ImportEmailAddress")), "", objEntity("ImportEmailAddress")))
                slParameters.Add("BirthDate", IIf(IsNothing(objEntity("BirthDate")), "1/1/1900", objEntity("BirthDate")))
                slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
                slParameters.Add("Active", IIf(IsNothing(objEntity("Active")), True, objEntity("Active")))

                If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspEditEntityByIdent", slParameters, True, dsEntity, dsMessage) Then

                    If Not dsEntity Is Nothing AndAlso
                        dsEntity.Tables.Count > 0 AndAlso
                        dsEntity.Tables(0).Rows.Count > 0 Then

                        bolSuccess = True

                    End If 'If Not dsResults Is Nothing 

                End If 'uspEditEntityByIdent

            Else

                bolAccessDenied = True

            End If ' If intIdent > 0 AndAlso Login.CheckUserAccessToEntityProfile(intIdent)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            EditEntityByIdent = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Function GetEntityNetwork(ByVal bolIncludePersons As Boolean, ByVal bolIncludeOrganizations As Boolean, ByRef dsResults As DataSet) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("AddEditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("IncludePersons", bolIncludePersons)
            slParameters.Add("IncludeOrganizations", bolIncludeOrganizations)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.ASUserIdent, "uspGetEntityNetwork", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 0 Then

                    dsResults.Tables(0).TableName = "EntityNetwork"

                    bolSuccess = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetEntityNetwork = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Function

    Public Shared Sub LogBulkAddImportEntity(ByVal strImportData As String)

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", Helper.ASUserIdent)
            slParameters.Add("ASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("ImportData", strImportData)

            Call Helper.SQLAdapter.ExecuteNonQuery(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspAddEntityNetworkImportHistory", slParameters, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)

        End Try

    End Sub

    Public Shared Sub SearchEntity(ByVal searchObject As EntitySearch, ByRef dsResults As System.Data.DataSet)

        Dim cmdCommand As System.Data.SqlClient.SqlCommand = Nothing
        Dim daDataAdapter As System.Data.SqlClient.SqlDataAdapter = Nothing
        Dim cnnConnection As System.Data.SqlClient.SqlConnection = Nothing
        Dim objFilter As EntitySearchFilter = Nothing
        Dim bolProjectFilter As Boolean = False

        Try

            'check if any of the filters are project filters
            For Each objFilter In searchObject.filters


                If objFilter.entitySearchFilterTypeIdent = Helper.enmEntitySearchFilterType.ProjectSpecific Or _
                    objFilter.entitySearchFilterTypeIdent = Helper.enmEntitySearchFilterType.Organizations Then
                    'treat organization search like project searches, we'll filter from there

                    bolProjectFilter = True

                    Exit For

                End If

            Next

            cnnConnection = New System.Data.SqlClient.SqlConnection
            cmdCommand = New System.Data.SqlClient.SqlCommand
            daDataAdapter = New SqlClient.SqlDataAdapter

            If cnnConnection.State = ConnectionState.Closed Then

                cnnConnection.ConnectionString = ConfigurationManager.ConnectionStrings("DatabaseConnectionString").ConnectionString
                cnnConnection.Open()

            End If

            With cmdCommand

                .Connection = cnnConnection
                .CommandType = CommandType.StoredProcedure
                .CommandTimeout = cnnConnection.ConnectionTimeout ' match the command timeout from the connection string (so we have a single variable that stores this value)
                .Parameters.Add("@bntEntityIdent", SqlDbType.BigInt).Value = Helper.ASUserIdent
                .Parameters.Add("@bntASUserIdent", SqlDbType.BigInt).Value = Helper.AddEditASUserIdent
                .Parameters.Add("@nvrKeyword", SqlDbType.NVarChar, -1).Value = searchObject.keyword
                .Parameters.Add("@nvrLocation", SqlDbType.NVarChar, -1).Value = searchObject.location
                .Parameters.Add("@decLatitude", SqlDbType.Decimal).Value = searchObject.latitude
                .Parameters.Add("@decLongitude", SqlDbType.Decimal).Value = searchObject.longitude
                .Parameters.Add("@intDistanceInMiles", SqlDbType.Int).Value = searchObject.radius
                .Parameters.Add("@bntResultsShown", SqlDbType.BigInt).Value = searchObject.resultsShown

                If searchObject.searchGlobal Then

                    .CommandText = "uspSearchEntityGlobalList"

                    .Parameters.Add("@bntSkipToIdent", SqlDbType.BigInt).Value = searchObject.SkipToIdent
                    .Parameters.Add("@bitSortByIdent", SqlDbType.Bit).Value = searchObject.SortByIdent

                    If searchObject.filters.Count > 0 Then

                        .Parameters.Add("@tblFilters", SqlDbType.Structured).Value = SQLDataTables.EntitySearchFilter(searchObject.filters)

                    End If

                Else ' entity search

                    If searchObject.fullProjectExport Then

                        .CommandText = "uspSearchEntityNetworkWithProjectExport"

                    ElseIf searchObject.addEntityProjectIdent > 0 Then

                        .CommandText = "uspSearchEntityNetworkWithBulkProjectAdd"
                        .Parameters.Add("@bntAddEntityProjectIdent", SqlDbType.BigInt).Value = searchObject.addEntityProjectIdent

                    ElseIf bolProjectFilter Then

                        'if its a project filter were going to pivot slightly different
                        .CommandText = "uspSearchEntityNetworkWithProjectFilters"

                    Else

                        .CommandText = "uspSearchEntityNetwork"

                    End If

                    If searchObject.filters.Count > 0 Then

                        .Parameters.Add("@tblFilters", SqlDbType.Structured).Value = SQLDataTables.EntitySearchFilter(searchObject.filters)

                    End If

                End If 'If searchObject.searchGlobal

                daDataAdapter.SelectCommand = cmdCommand
                daDataAdapter.Fill(dsResults)

            End With 'With cmdCommand

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            If Not cmdCommand Is Nothing Then

                cmdCommand.Dispose()

            End If

            If Not daDataAdapter Is Nothing Then

                daDataAdapter.Dispose()

            End If

            If Not cnnConnection Is Nothing Then

                If cnnConnection.State = ConnectionState.Open Then

                    cnnConnection.Close()

                End If

                cnnConnection.Dispose()

            End If

            Helper.CleanUp(cmdCommand)
            Helper.CleanUp(daDataAdapter)
            Helper.CleanUp(cnnConnection)
            Helper.CleanUp(objFilter)

        End Try

    End Sub

    Protected Shared Function UploadEntityProfilePhoto(ByVal strContentToUpload As String, ByVal intEntityIdent As Int64) As String

        Dim strProfilePhotoLink As String = ""
        Dim bytFileContents As Byte() = Nothing
        Dim strStringDate As String = ""
        Dim intThumbnailWidth As Integer = 0
        Dim strFileName As String = ""

        Try

            'remove the data info so we have our base64 image
            strContentToUpload = Replace(strContentToUpload, "data:image/jpeg;base64,", "")

            'convert our base64 to a byte array to save in Azure
            bytFileContents = System.Convert.FromBase64String(strContentToUpload)

            strStringDate = Now.ToString("yyyyMMddHHmmss")

            'store the string with the date so we can BUST CACHE
            strFileName = CType(intEntityIdent, String) & "_" & strStringDate & ".jpg"

            Call AzureFiles.UploadFileToAzure("profile-photos", strFileName, bytFileContents, Microsoft.WindowsAzure.Storage.Blob.BlobContainerPublicAccessType.Blob)

            intThumbnailWidth = Helper.GetASApplicationVariableByName1("EntityProfilePhotoThumbnailWidth")

            'once we upload the actual image, go and create the thumbnail (1/2 size)
            bytFileContents = Nothing
            bytFileContents = System.Convert.FromBase64String(Helper.ConvertBase64ImageStringToThumbnail(strContentToUpload, intThumbnailWidth))

            'add _thumb to the end of the filename (this will be stored in the db)
            strFileName = CType(intEntityIdent, String) & "_" & strStringDate & "_thumb.jpg"

            Call AzureFiles.UploadFileToAzure("profile-photos", strFileName, bytFileContents, Microsoft.WindowsAzure.Storage.Blob.BlobContainerPublicAccessType.Blob)

            strProfilePhotoLink = System.Configuration.ConfigurationManager.AppSettings("ProfilePhotoLink") & strFileName

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            UploadEntityProfilePhoto = strProfilePhotoLink

            Helper.CleanUp(bytFileContents)

        End Try

    End Function

    Public Shared Function ChangeEntityType(ByVal intEntityIdent As Int64, ByVal intEntityTypeIdent As Int64, ByVal strNPI As String, ByRef bolAccessDenied As Boolean, ByRef intNewEntityIdent As Int64) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Dim strSourceContainer As String = ""
        Dim strDestinationContainer As String = ""
        Dim strSourceFileName As String = ""
        Dim strDestinationFileName As String = ""
        Dim intRequirementTypeIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("EntityIdent", intEntityIdent)
            slParameters.Add("ASUserIdent", Helper.ASUserIdent)
            slParameters.Add("EditASUserIdent", Helper.AddEditASUserIdent)
            slParameters.Add("EntityTypeIdent", intEntityTypeIdent)
            slParameters.Add("NPI", strNPI)

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspUpdateEntityEntityTypeIdent", slParameters, True, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count = 2 AndAlso _
                    dsResults.Tables(0).Rows.Count > 0 Then

                    bolAccessDenied = dsResults.Tables(0).Rows(0)("AccessDenied")
                    intNewEntityIdent = CType(dsResults.Tables(0).Rows(0)("ToEntityIdent"), Int64)
                    
                    strSourceContainer = CType(intEntityIdent, String)
                    strDestinationContainer = CType(intNewEntityIdent, String)

                    For Each drRow As DataRow In dsResults.Tables(1).Rows

                        strSourceFileName = CType(drRow("OldFileAnswerIdent"), String) & ".enc"
                        strDestinationFileName = CType(drRow("NewFileAnswerIdent"), String) & ".enc"
                        intRequirementTypeIdent = CType(drRow("RequirementTypeIdent"), Int64)

                        If AzureFiles.MoveAzureFile(strSourceContainer, strDestinationContainer, strSourceFileName, strDestinationFileName) Then

                            'if its a question type of image, we need to generate a thumbnail for the preview
                            If intRequirementTypeIdent = Helper.enmRequirementType.ImageUpload Then

                                strSourceFileName = CType(drRow("OldFileAnswerIdent"), String) & "_thumb.enc"
                                strDestinationFileName = CType(drRow("NewFileAnswerIdent"), String) & "_thumb.enc"

                                Call AzureFiles.MoveAzureFile(strSourceContainer, strDestinationContainer, strSourceFileName, strDestinationFileName)

                            End If

                        End If 'If Helper.CopyAzureFile

                    Next

                    bolSuccess = True 'Success, that we completed the function, not that the stored procedure committed changes. Thats the Access Denied flag above

                End If 'If Not dsResults Is Nothing 

            End If 'uspUpdateEntityEntityTypeIdent

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            ChangeEntityType = bolSuccess

            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsMessage)
            Helper.CleanUp(dsResults)

        End Try

    End Function

End Class
