Imports System.IO
Imports System.Text
Imports System.Security.Cryptography

Public Class Encryption

    Protected Shared mintHashSize As Integer = 64
    Protected Shared mintKeySize As Integer = 256
    Protected Shared mintInterations As Integer = 10000
    Protected Shared mbytSalt() As Byte = Nothing

    Public Shared Function CreateHash(ByVal strTextToBeHashed As String, ByVal strSaltKey As String) As String

        Dim bytSalt() As Byte = Nothing
        Dim bytHash() As Byte = Nothing
        Dim pbkdf2 As Rfc2898DeriveBytes = Nothing

        Try

            bytSalt = Encoding.ASCII.GetBytes(strSaltKey.ToCharArray)

            pbkdf2 = New Rfc2898DeriveBytes(strTextToBeHashed, bytSalt)
            pbkdf2.IterationCount = mintInterations

            bytHash = pbkdf2.GetBytes(mintHashSize)

            Return Convert.ToBase64String(bytHash)

        Catch ex As Exception

            Return ""

        Finally

            Helper.CleanUp(bytHash)
            Helper.CleanUp(bytSalt)
            Helper.CleanUp(pbkdf2)

        End Try

    End Function

    Public Shared Function GenerateNewSalt() As String

        Dim objCsprng As New RNGCryptoServiceProvider()
        Dim bytSalt As Byte() = Nothing

        Try

            ' Generate a random salt
            bytSalt = New Byte(mintHashSize - 1) {}
            objCsprng.GetBytes(bytSalt)

            Return Convert.ToBase64String(bytSalt)

        Catch ex As Exception

            Return ""

        End Try

    End Function

    Public Shared Function GenerateNewEncryptionKey() As String

        Dim strKey As String = ""
        Dim rjndl As RijndaelManaged = Nothing

        Try

            ' Create instance of Rijndael for symetric encryption of the data.
            rjndl = New RijndaelManaged
            rjndl.KeySize = mintKeySize
            rjndl.BlockSize = mintKeySize
            rjndl.Mode = CipherMode.CBC

            strKey = System.Convert.ToBase64String(rjndl.Key)

            Return Left(strKey, 32)

        Catch ex As Exception

            Return ""

        Finally

            Helper.CleanUp(rjndl)

        End Try

    End Function

    Public Shared Function VerifyHashMatch(ByVal strPlainTextValue As String, _
                                            ByVal strHashedValue As String, _
                                            ByVal strSaltKey As String) As Boolean

        Dim bolSuccess As Boolean = False
        Dim strNewHash As String = ""

        Try

            strNewHash = CreateHash(strPlainTextValue, strSaltKey)

            If strNewHash = strHashedValue Then

                bolSuccess = True

            End If

        Catch ex As Exception

            bolSuccess = False

        Finally

            VerifyHashMatch = bolSuccess

        End Try

    End Function

    Public Shared Function EncryptFile(ByVal strBase64FileStringToEncrypt As String, ByVal strEncryptionKey As String) As String

        Dim objRijndl As RijndaelManaged = Nothing
        Dim objKey() As Byte = Nothing
        Dim objEncryptedBytes() As Byte = Nothing
        Dim objDecryptedBytes() As Byte = Nothing
        Dim objMemoryStream As MemoryStream = Nothing
        Dim objCryptoStream As CryptoStream = Nothing

        Dim strEncryptedString As String = ""

        Try

            strBase64FileStringToEncrypt = StripNullCharactersFromBase64String(strBase64FileStringToEncrypt)

            objMemoryStream = New MemoryStream()
            objDecryptedBytes = Encoding.ASCII.GetBytes(strBase64FileStringToEncrypt.ToCharArray)
            objKey = Encoding.ASCII.GetBytes(strEncryptionKey.ToCharArray)

            objRijndl = New RijndaelManaged
            objCryptoStream = New CryptoStream(objMemoryStream, objRijndl.CreateEncryptor(objKey, mbytSalt), CryptoStreamMode.Write)
            objCryptoStream.Write(objDecryptedBytes, 0, objDecryptedBytes.Length)
            objCryptoStream.FlushFinalBlock()

            objEncryptedBytes = objMemoryStream.ToArray

            objMemoryStream.Close()
            objCryptoStream.Close()

            strEncryptedString = Convert.ToBase64String(objEncryptedBytes)

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            EncryptFile = strEncryptedString

            Helper.CleanUp(objRijndl)
            Helper.CleanUp(objKey)
            Helper.CleanUp(objEncryptedBytes)
            Helper.CleanUp(objDecryptedBytes)
            Helper.CleanUp(objMemoryStream)
            Helper.CleanUp(objCryptoStream)

        End Try

    End Function

    Public Shared Function DecryptFile(ByVal strBase64FileStringToDecrypt As String, ByVal strEncryptionKey As String) As String

        Dim objRijndl As RijndaelManaged = Nothing
        Dim objKey() As Byte = Nothing
        Dim objEncryptedBytes() As Byte = Nothing
        Dim objDecryptedBytes() As Byte = Nothing
        Dim objMemoryStream As MemoryStream = Nothing
        Dim objCryptoStream As CryptoStream = Nothing

        Dim strDecryptedString As String = ""

        Try

            objRijndl = New RijndaelManaged

            'convert our base64 back to bytes
            objEncryptedBytes = Convert.FromBase64String(strBase64FileStringToDecrypt)
            objKey = Encoding.ASCII.GetBytes(strEncryptionKey.ToCharArray)

            ReDim objDecryptedBytes(objEncryptedBytes.Length)

            objMemoryStream = New MemoryStream(objEncryptedBytes)
            objCryptoStream = New CryptoStream(objMemoryStream, objRijndl.CreateDecryptor(objKey, mbytSalt), CryptoStreamMode.Read)
            objCryptoStream.Read(objDecryptedBytes, 0, objDecryptedBytes.Length)
            
            strDecryptedString = StripNullCharactersFromBase64String(Encoding.ASCII.GetString(objDecryptedBytes))

            objMemoryStream.Close()
            objCryptoStream.Close()

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            DecryptFile = strDecryptedString

            Helper.CleanUp(objRijndl)
            Helper.CleanUp(objKey)
            Helper.CleanUp(objEncryptedBytes)
            Helper.CleanUp(objDecryptedBytes)
            Helper.CleanUp(objMemoryStream)
            Helper.CleanUp(objCryptoStream)

        End Try

    End Function

    Private Shared Function StripNullCharactersFromBase64String(ByVal strInputString As String) As String

        Dim intPosition As Integer = 0
        Dim strStringWithOutNulls As String = ""

        Try

            intPosition = 1
            strStringWithOutNulls = strInputString

            Do While intPosition > 0

                intPosition = InStr(intPosition, strInputString, vbNullChar)

                If intPosition > 0 Then

                    strStringWithOutNulls = Left$(strStringWithOutNulls, intPosition - 1) & _
                       Right$(strStringWithOutNulls, Len(strStringWithOutNulls) - intPosition)

                End If

                If intPosition > strStringWithOutNulls.Length Then

                    Exit Do

                End If

            Loop

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            StripNullCharactersFromBase64String = strStringWithOutNulls

        End Try

    End Function

End Class
