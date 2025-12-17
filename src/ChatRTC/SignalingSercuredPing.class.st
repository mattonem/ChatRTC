Class {
	#name : 'SignalingSercuredPing',
	#superclass : 'Announcement',
	#instVars : [
		'address',
		'pubRSAKey'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingSercuredPing >> address [

	^ address
]

{ #category : 'accessing' }
SignalingSercuredPing >> address: anObject [

	address := anObject
]

{ #category : 'accessing' }
SignalingSercuredPing >> pubRSAKey [

	^ pubRSAKey
]

{ #category : 'accessing' }
SignalingSercuredPing >> pubRSAKey: anObject [

	pubRSAKey := anObject
]
