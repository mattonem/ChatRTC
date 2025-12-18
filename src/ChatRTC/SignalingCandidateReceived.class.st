Class {
	#name : 'SignalingCandidateReceived',
	#superclass : 'Announcement',
	#instVars : [
		'candidate'
	],
	#category : 'ChatRTC',
	#package : 'ChatRTC'
}

{ #category : 'accessing' }
SignalingCandidateReceived >> candidate [

	^ candidate
]

{ #category : 'accessing' }
SignalingCandidateReceived >> candidate: anObject [

	candidate := anObject
]
