Class {
	#name : 'SignalingContact',
	#superclass : 'Object',
	#instVars : [
		'announcer',
		'pubRSAKey',
		'originAddress',
		'originRSAKey',
		'address',
		'open'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingContact >> address [

	^ address
]

{ #category : 'accessing' }
SignalingContact >> address: anObject [

	address := anObject
]

{ #category : 'as yet unclassified' }
SignalingContact >> announcer [

	^ announcer
]

{ #category : 'as yet unclassified' }
SignalingContact >> close [

	open := false.
	announcer announce: (SignalingStatus new status: #close)
]

{ #category : 'as yet unclassified' }
SignalingContact >> initialize [

	announcer := Announcer new.
	open := false.
]

{ #category : 'accessing' }
SignalingContact >> isOpen [

	^ open
]

{ #category : 'accessing' }
SignalingContact >> isVerified [

	^ pubRSAKey isNotNil
]

{ #category : 'as yet unclassified' }
SignalingContact >> open [

	open := true.
	announcer announce: (SignalingStatus new status: #open)
]

{ #category : 'accessing' }
SignalingContact >> originAddress: anObject [

	originAddress := anObject
]

{ #category : 'accessing' }
SignalingContact >> originRSAKey: anObject [

	originRSAKey := anObject
]

{ #category : 'as yet unclassified' }
SignalingContact >> ping [
	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
SignalingContact >> postCopy [

	super postCopy.
	announcer := Announcer new
]

{ #category : 'accessing' }
SignalingContact >> pubRSAKey [

	^ pubRSAKey
]

{ #category : 'accessing' }
SignalingContact >> pubRSAKey: anObject [

	pubRSAKey := anObject.
	announcer announce: SignalingContactIsSecured new
]

{ #category : 'accessing' }
SignalingContact >> send: aMessage [

	self subclassResponsibility
]
