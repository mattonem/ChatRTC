|newRepository|
Smalltalk vm maxExternalSemaphoresSilently: 1000.
newRepository := IceRepositoryCreator new
				repository: nil;
				location: '.' asFileReference ;
				createRepository .
newRepository register.

ChatRTC appFolder: './build' asFileLocatorOrReference ensureCreateDirectory.
ChatRTC exportApp.