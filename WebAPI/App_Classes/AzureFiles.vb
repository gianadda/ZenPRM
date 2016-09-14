Imports Microsoft.WindowsAzure.Storage
Imports Microsoft.WindowsAzure.Storage.Blob
Imports AzureEncryptionExtensions

Public Class AzureFiles

    Public Shared Function UploadFileToAzure(ByVal containerName As String, ByVal fileName As String, ByVal fileArray As Byte(), _
                                                   Optional ByVal enmAzureAccessType As BlobContainerPublicAccessType = BlobContainerPublicAccessType.Off) As Boolean

        Dim storageAccount As CloudStorageAccount = Nothing
        Dim blobClient As CloudBlobClient = Nothing
        Dim container As CloudBlobContainer = Nothing
        Dim permissions As BlobContainerPermissions = Nothing
        Dim blockBlob As CloudBlockBlob = Nothing
        Dim bolSuccess As Boolean = False

        Try

            'Need to ensure that the container name is at least 5 characters (Azure requires at least 3, we are just being safe)
            If containerName.Length < 5 Then

                containerName = Right("00000" & containerName, 5)

            End If

            storageAccount = CloudStorageAccount.Parse(System.Configuration.ConfigurationManager.AppSettings("AzureStorageConnectionSting"))

            blobClient = storageAccount.CreateCloudBlobClient()

            container = blobClient.GetContainerReference(containerName)
            container.CreateIfNotExists()

            permissions = New BlobContainerPermissions()
            permissions.PublicAccess = enmAzureAccessType
            container.SetPermissions(permissions)

            blockBlob = container.GetBlockBlobReference(fileName)
            blockBlob.UploadFromByteArray(fileArray, 0, fileArray.Length)

            'If the upload was successful
            If blockBlob.Exists Then

                bolSuccess = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            UploadFileToAzure = bolSuccess

            Helper.CleanUp(storageAccount)
            Helper.CleanUp(blobClient)
            Helper.CleanUp(container)
            Helper.CleanUp(permissions)
            Helper.CleanUp(blockBlob)

        End Try

    End Function

    Public Shared Function UploadFileTextToAzure(ByVal containerName As String, ByVal fileName As String, ByVal fileContents As String) As Boolean

        Dim storageAccount As CloudStorageAccount = Nothing
        Dim blobClient As CloudBlobClient = Nothing
        Dim container As CloudBlobContainer = Nothing
        Dim permissions As BlobContainerPermissions = Nothing
        Dim blockBlob As CloudBlockBlob = Nothing
        Dim bolSuccess As Boolean = False

        Try

            'Need to ensure that the container name is at least 5 characters (Azure requires at least 3, we are just being safe)
            If containerName.Length < 5 Then

                containerName = Right("00000" & containerName, 5)

            End If

            storageAccount = CloudStorageAccount.Parse(System.Configuration.ConfigurationManager.AppSettings("AzureStorageConnectionSting"))

            blobClient = storageAccount.CreateCloudBlobClient()

            container = blobClient.GetContainerReference(containerName)
            container.CreateIfNotExists()

            permissions = New BlobContainerPermissions()
            permissions.PublicAccess = BlobContainerPublicAccessType.Off
            container.SetPermissions(permissions)

            blockBlob = container.GetBlockBlobReference(fileName)
            blockBlob.UploadText(fileContents)

            'If the upload was successful
            If blockBlob.Exists Then

                bolSuccess = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            UploadFileTextToAzure = bolSuccess

            Helper.CleanUp(storageAccount)
            Helper.CleanUp(blobClient)
            Helper.CleanUp(container)
            Helper.CleanUp(permissions)
            Helper.CleanUp(blockBlob)

        End Try

    End Function

    Public Shared Function CopyAzureFile(ByVal containerName As String, ByVal sourceFileName As String, ByVal destinationFileName As String) As Boolean

        Dim storageAccount As CloudStorageAccount = Nothing
        Dim blobClient As CloudBlobClient = Nothing
        Dim container As CloudBlobContainer = Nothing
        Dim permissions As BlobContainerPermissions = Nothing

        Dim sourceBlob As CloudBlockBlob = Nothing
        Dim destinationBlob As CloudBlockBlob = Nothing

        Dim bolSuccess As Boolean = False

        Try

            'Need to ensure that the container name is at least 5 characters (Azure requires at least 3, we are just being safe)
            If containerName.Length < 5 Then

                containerName = Right("00000" & containerName, 5)

            End If

            storageAccount = CloudStorageAccount.Parse(System.Configuration.ConfigurationManager.AppSettings("AzureStorageConnectionSting"))

            blobClient = storageAccount.CreateCloudBlobClient()

            container = blobClient.GetContainerReference(containerName)
            container.CreateIfNotExists()

            permissions = New BlobContainerPermissions()
            permissions.PublicAccess = BlobContainerPublicAccessType.Off
            container.SetPermissions(permissions)

            sourceBlob = container.GetBlockBlobReference(sourceFileName)

            If sourceBlob.Exists Then

                destinationBlob = container.GetBlockBlobReference(destinationFileName)
                destinationBlob.StartCopy(sourceBlob)

                If destinationBlob.Exists Then

                    bolSuccess = True

                End If ' If destinationBlob.Exists

            End If 'If sourceBlob.Exists

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            CopyAzureFile = bolSuccess

            Helper.CleanUp(storageAccount)
            Helper.CleanUp(blobClient)
            Helper.CleanUp(container)
            Helper.CleanUp(permissions)
            Helper.CleanUp(destinationBlob)
            Helper.CleanUp(sourceBlob)

        End Try

    End Function

    Public Shared Function MoveAzureFile(ByVal sourceContainerName As String, ByVal destinationContainerName As String, ByVal sourceFileName As String, ByVal destinationFileName As String) As Boolean

        Dim storageAccount As CloudStorageAccount = Nothing
        Dim blobClient As CloudBlobClient = Nothing
        Dim permissions As BlobContainerPermissions = Nothing

        Dim sourceContainer As CloudBlobContainer = Nothing
        Dim destinationContainer As CloudBlobContainer = Nothing

        Dim sourceBlob As CloudBlockBlob = Nothing
        Dim destinationBlob As CloudBlockBlob = Nothing

        Dim bolSuccess As Boolean = False

        Try

            'Need to ensure that the container name is at least 5 characters (Azure requires at least 3, we are just being safe)
            If sourceContainerName.Length < 5 Then

                sourceContainerName = Right("00000" & sourceContainerName, 5)

            End If

            If destinationContainerName.Length < 5 Then

                destinationContainerName = Right("00000" & destinationContainerName, 5)

            End If

            storageAccount = CloudStorageAccount.Parse(System.Configuration.ConfigurationManager.AppSettings("AzureStorageConnectionSting"))

            blobClient = storageAccount.CreateCloudBlobClient()

            sourceContainer = blobClient.GetContainerReference(sourceContainerName)

            destinationContainer = blobClient.GetContainerReference(destinationContainerName)
            destinationContainer.CreateIfNotExists()

            permissions = New BlobContainerPermissions()
            permissions.PublicAccess = BlobContainerPublicAccessType.Off
            destinationContainer.SetPermissions(permissions)

            sourceBlob = sourceContainer.GetBlockBlobReference(sourceFileName)

            If sourceBlob.Exists Then

                destinationBlob = destinationContainer.GetBlockBlobReference(destinationFileName)
                destinationBlob.StartCopy(sourceBlob)

                If destinationBlob.Exists Then

                    bolSuccess = True

                End If ' If destinationBlob.Exists

            End If 'If sourceBlob.Exists

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            MoveAzureFile = bolSuccess

            Helper.CleanUp(storageAccount)
            Helper.CleanUp(blobClient)
            Helper.CleanUp(destinationContainer)
            Helper.CleanUp(sourceContainer)
            Helper.CleanUp(permissions)
            Helper.CleanUp(destinationBlob)
            Helper.CleanUp(sourceBlob)

        End Try

    End Function

    Public Shared Function DownloadFileFromAzure(ByVal containerName As String, ByVal fileName As String, ByRef fileArray As Byte()) As Boolean

        Dim storageAccount As CloudStorageAccount = Nothing
        Dim blobClient As CloudBlobClient = Nothing
        Dim container As CloudBlobContainer = Nothing
        Dim permissions As BlobContainerPermissions = Nothing
        Dim blockBlob As CloudBlockBlob = Nothing
        Dim bolSuccess As Boolean = False

        Try

            'Need to ensure that the container name is at least 5 characters (Azure requires at least 3, we are just being safe)
            If containerName.Length < 5 Then

                containerName = Right("00000" & containerName, 5)

            End If

            storageAccount = CloudStorageAccount.Parse(System.Configuration.ConfigurationManager.AppSettings("AzureStorageConnectionSting"))

            blobClient = storageAccount.CreateCloudBlobClient()

            container = blobClient.GetContainerReference(containerName)

            blockBlob = container.GetBlockBlobReference(fileName)

            If blockBlob.Exists() Then

                blockBlob.FetchAttributes()
                fileArray = New Byte(blockBlob.Properties.Length) {}

                blockBlob.DownloadToByteArray(fileArray, 0)

                bolSuccess = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            DownloadFileFromAzure = bolSuccess

            Helper.CleanUp(storageAccount)
            Helper.CleanUp(blobClient)
            Helper.CleanUp(container)
            Helper.CleanUp(permissions)
            Helper.CleanUp(blockBlob)

        End Try

    End Function

    Public Shared Function DownloadFileTextFromAzure(ByVal containerName As String, ByVal fileName As String, ByRef fileContents As String) As Boolean

        Dim storageAccount As CloudStorageAccount = Nothing
        Dim blobClient As CloudBlobClient = Nothing
        Dim container As CloudBlobContainer = Nothing
        Dim permissions As BlobContainerPermissions = Nothing
        Dim blockBlob As CloudBlockBlob = Nothing
        Dim bolSuccess As Boolean = False

        Try

            'Need to ensure that the container name is at least 5 characters (Azure requires at least 3, we are just being safe)
            If containerName.Length < 5 Then

                containerName = Right("00000" & containerName, 5)

            End If

            storageAccount = CloudStorageAccount.Parse(System.Configuration.ConfigurationManager.AppSettings("AzureStorageConnectionSting"))

            blobClient = storageAccount.CreateCloudBlobClient()

            container = blobClient.GetContainerReference(containerName)

            blockBlob = container.GetBlockBlobReference(fileName)

            If blockBlob.Exists() Then

                blockBlob.FetchAttributes()

                fileContents = blockBlob.DownloadText()

                bolSuccess = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            DownloadFileTextFromAzure = bolSuccess

            Helper.CleanUp(storageAccount)
            Helper.CleanUp(blobClient)
            Helper.CleanUp(container)
            Helper.CleanUp(permissions)
            Helper.CleanUp(blockBlob)

        End Try

    End Function

    Public Shared Function DownloadEncryptedFileFromAzure(ByVal containerName As String, ByVal fileName As String, ByVal destinationPath As String, ByVal encryptionKey As String) As Boolean

        Dim storageAccount As CloudStorageAccount = Nothing
        Dim blobClient As CloudBlobClient = Nothing
        Dim container As CloudBlobContainer = Nothing
        Dim permissions As BlobContainerPermissions = Nothing
        Dim blockBlob As CloudBlockBlob = Nothing
        Dim bolSuccess As Boolean = False

        Dim strEncryptedFileName As String = ""

        Dim provider As AzureEncryptionExtensions.Providers.SymmetricBlobCryptoProvider = Nothing
        Dim objKey() As Byte = Nothing

        Try

            'the files are stored as .enc files
            strEncryptedFileName = Replace(fileName, ".zip", ".enc")

            'Need to ensure that the container name is at least 5 characters (Azure requires at least 3, we are just being safe)
            If containerName.Length < 5 Then

                containerName = Right("00000" & containerName, 5)

            End If

            storageAccount = CloudStorageAccount.Parse(System.Configuration.ConfigurationManager.AppSettings("AzureStorageConnectionSting"))

            blobClient = storageAccount.CreateCloudBlobClient()

            container = blobClient.GetContainerReference(containerName)

            blockBlob = container.GetBlockBlobReference(strEncryptedFileName)

            objKey = Encoding.ASCII.GetBytes(encryptionKey.ToCharArray)
            provider = New Providers.SymmetricBlobCryptoProvider(objKey)

            If blockBlob.Exists() Then

                blockBlob.FetchAttributes()

                If Not System.IO.Directory.Exists(destinationPath) Then

                    System.IO.Directory.CreateDirectory(destinationPath)

                End If

                blockBlob.DownloadToFileEncrypted(provider, destinationPath & fileName, IO.FileMode.Create)

                bolSuccess = True

            End If

        Catch ex As Exception

            Messaging.LogError(ex)

        Finally

            DownloadEncryptedFileFromAzure = bolSuccess

            Helper.CleanUp(storageAccount)
            Helper.CleanUp(blobClient)
            Helper.CleanUp(container)
            Helper.CleanUp(permissions)
            Helper.CleanUp(blockBlob)

        End Try

    End Function

End Class
