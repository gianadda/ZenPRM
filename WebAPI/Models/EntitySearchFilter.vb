Public Class EntitySearchFilter

    Private intEntitySearchFilterTypeIdent As Int64 = 0
    Private intEntitySearchOperatorIdent As Int64 = 0
    Private intEntityProjectRequirementIdent As Int64 = 0
    Private intReferenceIdent As Int64 = 0
    Private strSearchValue As String = ""

    Public Property entitySearchFilterTypeIdent() As Int64
        Get
            Return intEntitySearchFilterTypeIdent
        End Get
        Set(value As Int64)
            intEntitySearchFilterTypeIdent = value
        End Set
    End Property

    Public Property entitySearchOperatorIdent() As Int64
        Get
            Return intEntitySearchOperatorIdent
        End Get
        Set(value As Int64)
            intEntitySearchOperatorIdent = value
        End Set
    End Property

    Public Property entityProjectRequirementIdent() As Int64
        Get
            Return intEntityProjectRequirementIdent
        End Get
        Set(value As Int64)
            intEntityProjectRequirementIdent = value
        End Set
    End Property

    Public Property referenceIdent() As Int64
        Get
            Return intReferenceIdent
        End Get
        Set(value As Int64)
            intReferenceIdent = value
        End Set
    End Property

    Public Property searchValue() As String
        Get
            Return strSearchValue
        End Get
        Set(value As String)
            strSearchValue = value
        End Set
    End Property

End Class
