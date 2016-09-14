Public Class EntityProjectMeasureRange

    Private intIdent As Int64 = 0
    Private intEntityProjectMeasureIdent As Int64 = 0
    Private strName1 As String = ""
    Private strColor As String = ""
    Private decRangeStartValue As Decimal = 0.0
    Private decRangeEndValue As Decimal = 0.0

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

    Public Property Label() As String
        Get
            Return strName1
        End Get
        Set(value As String)
            strName1 = value
        End Set
    End Property

    Public Property Color() As String
        Get
            Return strColor
        End Get
        Set(value As String)
            strColor = value
        End Set
    End Property

    Public Property Low() As Decimal
        Get
            Return decRangeStartValue
        End Get
        Set(value As Decimal)
            decRangeStartValue = value
        End Set
    End Property

    Public Property High() As Decimal
        Get
            Return decRangeEndValue
        End Get
        Set(value As Decimal)
            decRangeEndValue = value
        End Set
    End Property

End Class
