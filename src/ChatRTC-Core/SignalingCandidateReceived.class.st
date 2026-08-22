Class {
	#name : 'SignalingCandidateReceived',
	#superclass : 'Announcement',
	#instVars : [
		'candidate'
	],
	#category : 'ChatRTC-Core',
	#package : 'ChatRTC-Core'
}

{ #category : 'accessing' }
SignalingCandidateReceived >> candidate [

	^ candidate
]

{ #category : 'accessing' }
SignalingCandidateReceived >> candidate: anObject [

	candidate := anObject
]
