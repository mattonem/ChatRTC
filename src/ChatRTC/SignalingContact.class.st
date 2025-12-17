Class {
	#name : 'SignalingContact',
	#superclass : 'Object',
	#instVars : [
		'announcer',
		'pubRSAKey',
		'originAddress',
		'originRSAKey'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'as yet unclassified' }
SignalingContact >> announcer [

	^ announcer
]

{ #category : 'as yet unclassified' }
SignalingContact >> initialize [

	announcer := Announcer new
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
SignalingContact >> ping: address [
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
