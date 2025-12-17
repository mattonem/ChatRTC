Class {
	#name : 'SignalingStatus',
	#superclass : 'Announcement',
	#instVars : [
		'status'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'as yet unclassified' }
SignalingStatus class >> closed [

	^ self new status: #closed
]

{ #category : 'as yet unclassified' }
SignalingStatus class >> open [

	^ self new status: #open
]

{ #category : 'accessing' }
SignalingStatus >> status [

	^ status
]

{ #category : 'accessing' }
SignalingStatus >> status: anObject [

	status := anObject
]
