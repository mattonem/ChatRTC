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
		announcer announce: SignalingStatus closed
]

{ #category : 'as yet unclassified' }
SignalingClient >> isOpen [

	announcer announce: SignalingStatus open
]

{ #category : 'instance creation' }
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
