Public Class EntitySearch

    Private strName1 As String = ""
    Private strDesc1 As String = ""
    Private strCategory As String = ""
    Private bolBookmarkSearch As Boolean = False
    Private strKeyword As String = ""
    Private strLocation As String = ""
    Private decLatitude As Decimal = 0.0
    Private decLongitude As Decimal = 0.0
    Private intRadius As Integer = 0
    Private intResultsShown As Integer = 0
    Private bolFullProjectExport As Boolean = False
    Private bolSearchGlobal As Boolean = False
    Private intSkipToIdent As Integer = 0
    Private bolSortByIdent As Boolean = False
    Private intAddEntityProjectIdent As Int64 = 0
    Private strAddEntityIdents As String = ""
    Private intXAxisEntityProjectRequirementIdent As Int64 = 0
    Private intYAxisEntityProjectRequirementIdent As Int64 = 0
    Private intZAxisEntityProjectRequirementIdent As Int64 = 0
    Private intAlphaAxisEntityProjectRequirementIdent As Int64 = 0
    Private intActivityTypeGroupIdent As Int64 = 0
    Private intActivityDate As Integer = 0
    Private intPageNumber As Integer = 1
    Private bolPageChanged As Boolean = False
    Private objFilters As List(Of EntitySearchFilter)

    Public Property name() As String
        Get
            Return strName1
        End Get
        Set(value As String)
            strName1 = value
        End Set
    End Property

    Public Property description() As String
        Get
            Return strDesc1
        End Get
        Set(value As String)
            strDesc1 = value
        End Set
    End Property

    Public Property category() As String
        Get
            Return strCategory
        End Get
        Set(value As String)
            strCategory = value
        End Set
    End Property

    Public Property bookmark() As Boolean
        Get
            Return bolBookmarkSearch
        End Get
        Set(value As Boolean)
            bolBookmarkSearch = value
        End Set
    End Property
    Public Property keyword() As String
        Get
            Return strKeyword
        End Get
        Set(value As String)
            strKeyword = value
        End Set
    End Property

    Public Property location() As String
        Get
            Return strLocation
        End Get
        Set(value As String)
            strLocation = value
        End Set
    End Property

    Public Property latitude() As Decimal
        Get
            Return decLatitude
        End Get
        Set(value As Decimal)
            decLatitude = value
        End Set
    End Property

    Public Property longitude() As Decimal
        Get
            Return decLongitude
        End Get
        Set(value As Decimal)
            decLongitude = value
        End Set
    End Property

    Public Property radius() As Integer
        Get
            Return intRadius
        End Get
        Set(value As Integer)
            intRadius = value
        End Set
    End Property

    Public Property resultsShown() As Integer
        Get
            Return intResultsShown
        End Get
        Set(value As Integer)
            intResultsShown = value
        End Set
    End Property

    Public Property SkipToIdent() As Integer
        Get
            Return intSkipToIdent
        End Get
        Set(value As Integer)
            intSkipToIdent = value
        End Set
    End Property

    Public Property SortByIdent() As Boolean
        Get
            Return bolSortByIdent
        End Get
        Set(value As Boolean)
            bolSortByIdent = value
        End Set
    End Property

    Public Property fullProjectExport() As Boolean
        Get
            Return bolFullProjectExport
        End Get
        Set(value As Boolean)
            bolFullProjectExport = value
        End Set
    End Property

    Public Property searchGlobal() As Boolean
        Get
            Return bolSearchGlobal
        End Get
        Set(value As Boolean)
            bolSearchGlobal = value
        End Set
    End Property

    Public Property addEntityProjectIdent() As Int64
        Get
            Return intAddEntityProjectIdent
        End Get
        Set(value As Int64)
            intAddEntityProjectIdent = value
        End Set
    End Property

    Public Property addEntityIdents() As String
        Get
            Return strAddEntityIdents
        End Get
        Set(value As String)
            strAddEntityIdents = value
        End Set
    End Property

    Public Property XAxisEntityProjectRequirementIdent() As Int64
        Get
            Return intXAxisEntityProjectRequirementIdent
        End Get
        Set(value As Int64)
            intXAxisEntityProjectRequirementIdent = value
        End Set
    End Property

    Public Property YAxisEntityProjectRequirementIdent() As Int64
        Get
            Return intYAxisEntityProjectRequirementIdent
        End Get
        Set(value As Int64)
            intYAxisEntityProjectRequirementIdent = value
        End Set
    End Property

    Public Property ZAxisEntityProjectRequirementIdent() As Int64
        Get
            Return intZAxisEntityProjectRequirementIdent
        End Get
        Set(value As Int64)
            intZAxisEntityProjectRequirementIdent = value
        End Set
    End Property

    Public Property AlphaAxisEntityProjectRequirementIdent() As Int64
        Get
            Return intAlphaAxisEntityProjectRequirementIdent
        End Get
        Set(value As Int64)
            intAlphaAxisEntityProjectRequirementIdent = value
        End Set
    End Property

    Public Property activityTypeGroupIdent() As Int64
        Get
            Return intActivityTypeGroupIdent
        End Get
        Set(value As Int64)
            intActivityTypeGroupIdent = value
        End Set
    End Property

    Public Property activityDate() As Integer
        Get
            Return intActivityDate
        End Get
        Set(value As Integer)
            intActivityDate = value
        End Set
    End Property

    Public Property pageNumber() As Integer
        Get
            Return intPageNumber
        End Get
        Set(value As Integer)
            intPageNumber = value
        End Set
    End Property

    Public Property pageChanged() As Boolean
        Get
            Return bolPageChanged
        End Get
        Set(value As Boolean)
            bolPageChanged = value
        End Set
    End Property

    Public Property filters() As List(Of EntitySearchFilter)
        Get
            If IsNothing(objFilters) Then
                objFilters = New List(Of EntitySearchFilter)
            End If
            Return objFilters
        End Get
        Set(value As List(Of EntitySearchFilter))
            objFilters = value
        End Set
    End Property

End Class
