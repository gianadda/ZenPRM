Public Class EntityProjectMeasureLocation

    Private intIdent As Int64 = 0
    Private intEntityProjectMeasureIdent As Int64 = 0
    Private intMeasureLocationIdent As Int64 = 0
    Private strLocationName As String = ""
    Private bolSelected As Boolean = False

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

    Public Property MeasureLocationIdent() As Int64
        Get
            Return intMeasureLocationIdent
        End Get
        Set(value As Int64)
            intMeasureLocationIdent = value
        End Set
    End Property

    Public Property LocationName() As String
        Get
            Return strLocationName
        End Get
        Set(value As String)
            strLocationName = value
        End Set
    End Property

    Public Property Selected() As Boolean
        Get
            Return bolSelected
        End Get
        Set(value As Boolean)
            bolSelected = value
        End Set
    End Property

End Class
