Class {
	#name : 'SignalingClient',
	#superclass : 'Object',
	#instVars : [
		'announcer',
		'privateRSAKey',
		'contacts',
		'address',
		'publicRSAKey'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'as yet unclassified' }
SignalingClient >> announcer [

	^ announcer
]

{ #category : 'as yet unclassified' }
SignalingClient >> close [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
SignalingClient >> contacts [

	^ contacts
]

{ #category : 'as yet unclassified' }
SignalingClient >> initialize [

	announcer := Announcer new.
	contacts := Dictionary new.
]

{ #category : 'as yet unclassified' }
SignalingClient >> isClosed [
	^ self isOpen not
]

{ #category : 'as yet unclassified' }
SignalingClient >> isOpen [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
SignalingClient >> open [

	self subclassResponsibility 
]

{ #category : 'as yet unclassified' }
SignalingClient >> postCopy [

	super postCopy.
	announcer := Announcer new.
	contacts := Dictionary new.
]

{ #category : 'as yet unclassified' }
SignalingClient >> privateRSAKey: anObject [
	privateRSAKey := anObject
]
