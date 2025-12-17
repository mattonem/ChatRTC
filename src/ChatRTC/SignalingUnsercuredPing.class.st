Class {
	#name : 'SignalingUnsercuredPing',
	#superclass : 'Announcement',
	#instVars : [
		'address',
		'pubRSAKey'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingUnsercuredPing >> address [

	^ address
]

{ #category : 'accessing' }
SignalingUnsercuredPing >> address: anObject [

	address := anObject
]

{ #category : 'accessing' }
SignalingUnsercuredPing >> pubRSAKey [

	^ pubRSAKey
]

{ #category : 'accessing' }
SignalingUnsercuredPing >> pubRSAKey: anObject [

	pubRSAKey := anObject
]
