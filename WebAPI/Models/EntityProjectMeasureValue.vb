Public Class EntityProjectMeasureValue

    Private intIdent As Int64 = 0
    Private intEntityProjectMeasureIdent As Int64 = 0
    Private intOrganizationIdent As Int64 = 0
    Private strValue1 As String = ""
    Private intValueCount As Int64 = 0

    Public Property Ident() As Int64
        Get
            Return intIdent
        End Get
        Set(value As Int64)
            intIdent = value
        End Set
    End Property

    Public Property EntityProjectMeasureIdent() As Int64
        Get
            Return intEntityProjectMeasureIdent
        End Get
        Set(value As Int64)
            intEntityProjectMeasureIdent = value
        End Set
    End Property

    Public Property OrganizationIdent() As Int64
        Get
            Return intOrganizationIdent
        End Get
        Set(value As Int64)
            intOrganizationIdent = value
        End Set
    End Property

    Public Property Value1() As String
        Get
            Return strValue1
        End Get
        Set(value As String)
            strValue1 = value
        End Set
    End Property

    Public Property ValueCount() As Int64
        Get
            Return intValueCount
        End Get
        Set(value As Int64)
            intValueCount = value
        End Set
    End Property

End Class
