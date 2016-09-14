Public Class LookupTables

    Public Shared Function GetImportColumns(ByRef dtImportColumn As DataTable) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim dsResults As DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetAllActiveImportColumn", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count > 0 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    dsResults.Tables(0).TableName = "ImportColumns"
                    dtImportColumn = dsResults.Tables("ImportColumns")

                    bolSuccess = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetImportColumns = bolSuccess

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)
            Helper.CleanUp(dsResults)

        End Try

    End Function

    Public Shared Function GetLookupTables(ByRef dsResults As DataSet) As Boolean

        Dim slParameters As SortedList = Nothing
        Dim dsMessage As DataSet = Nothing
        Dim bolSuccess As Boolean = False

        Try

            slParameters = New SortedList

            If Helper.SQLAdapter.GetDataSet(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetLookupTables", slParameters, False, dsResults, dsMessage) Then

                If Not dsResults Is Nothing AndAlso
                    dsResults.Tables.Count >= 24 AndAlso
                    dsResults.Tables(0).Rows.Count > 0 Then

                    dsResults.Tables(0).TableName = "PCMHStatus"
                    dsResults.Tables(1).TableName = "Taxonomy"
                    dsResults.Tables(2).TableName = "Services"
                    dsResults.Tables(3).TableName = "Payor"
                    dsResults.Tables(4).TableName = "Language"
                    dsResults.Tables(5).TableName = "MeaningfulUse"
                    dsResults.Tables(6).TableName = "Gender"
                    dsResults.Tables(7).TableName = "Speciality"
                    dsResults.Tables(8).TableName = "States"
                    dsResults.Tables(9).TableName = "Degree"
                    dsResults.Tables(10).TableName = "EntityType"
                    dsResults.Tables(11).TableName = "ConnectionType"
                    dsResults.Tables(12).TableName = "InteractionType"
                    dsResults.Tables(13).TableName = "SystemType"
                    dsResults.Tables(14).TableName = "ToDoType"
                    dsResults.Tables(15).TableName = "EntitySearchDataType"
                    dsResults.Tables(16).TableName = "EntitySearchFilterType"
                    dsResults.Tables(17).TableName = "EntitySearchOperator"
                    dsResults.Tables(18).TableName = "ActivityTypeGroup"
                    dsResults.Tables(19).TableName = "MeasureType"
                    dsResults.Tables(20).TableName = "HierarchyType"
                    dsResults.Tables(21).TableName = "ToDoInitiatorType"
                    dsResults.Tables(22).TableName = "ToDoStatus"
                    dsResults.Tables(23).TableName = "MeasureLocation"

                    bolSuccess = True

                End If

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetLookupTables = bolSuccess

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Public Shared Function GetGenderIdentByName(ByVal strGender As String) As Int64

        Dim dsMessage As DataSet = Nothing
        Dim slParameters As SortedList = Nothing
        Dim intIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("Name1", strGender)

            Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetGenderIdentByName", slParameters, intIdent, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetGenderIdentByName = intIdent

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

    Public Shared Function GetStatesIdentByName(ByVal strState As String) As Int64

        Dim dsMessage As DataSet = Nothing
        Dim slParameters As SortedList = Nothing
        Dim intIdent As Int64 = 0

        Try

            slParameters = New SortedList
            slParameters.Add("Name1", strState)

            Helper.SQLAdapter.ExecuteScalar(Helper.ApplicationName, Helper.AddEditASUserIdent, "uspGetStatesIdentByName1", slParameters, intIdent, dsMessage)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            GetStatesIdentByName = intIdent

            Helper.CleanUp(dsMessage)
            Helper.CleanUp(slParameters)

        End Try

    End Function

End Class
