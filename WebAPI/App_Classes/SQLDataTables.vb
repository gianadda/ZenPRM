Public Class SQLDataTables

    Public Shared Function EntitySearchFilter(ByVal filters As IEnumerable(Of EntitySearchFilter)) As DataTable

        Dim dtFilters As New DataTable()
        Dim filter As EntitySearchFilter = Nothing
        Dim drRow As DataRow = Nothing
        Dim intCurrentIdent As Integer = 0

        Try

            dtFilters.Columns.Add("Ident", GetType(Int64))
            dtFilters.Columns.Add("EntitySearchFilterTypeIdent", GetType(Int64))
            dtFilters.Columns.Add("EntitySearchOperatorIdent", GetType(Int64))
            dtFilters.Columns.Add("EntityProjectRequirementIdent", GetType(Int64))
            dtFilters.Columns.Add("ReferenceIdent", GetType(Int64))
            dtFilters.Columns.Add("SearchValue", GetType(String))

            For Each filter In filters

                intCurrentIdent += 1

                drRow = dtFilters.NewRow

                'Tried using IDENTITY on the Ident column on the table type in SQL, but T-SQL wont let you pass 5 params into a 6 param table
                'Then tried adding the column but not filling, and T-SQL didnt allow that either. So manually creating an Ident here
                'The ident column is only used as a reference within the proc, and isnt needed to persist outside of it
                drRow("Ident") = intCurrentIdent
                drRow("EntitySearchFilterTypeIdent") = filter.entitySearchFilterTypeIdent
                drRow("EntitySearchOperatorIdent") = filter.entitySearchOperatorIdent
                drRow("EntityProjectRequirementIdent") = filter.entityProjectRequirementIdent
                drRow("ReferenceIdent") = filter.referenceIdent
                drRow("SearchValue") = filter.searchValue

                dtFilters.Rows.Add(drRow)

            Next

            Return dtFilters

        Catch ex As Exception

            Messaging.LogError(ex)

            Return Nothing

        Finally

            Helper.CleanUp(dtFilters)
            Helper.CleanUp(filter)
            Helper.CleanUp(drRow)

        End Try

    End Function


End Class
