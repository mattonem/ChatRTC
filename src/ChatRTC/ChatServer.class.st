Class {
	#name : 'ChatServer',
	#superclass : 'WebJobWorker',
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'start-stop' }
ChatServer >> onMessage: anObject [

	^ anObject, ' treated'
]
